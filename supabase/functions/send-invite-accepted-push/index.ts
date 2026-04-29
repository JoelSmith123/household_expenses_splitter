import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

const safeNotificationField = (value: string | null | undefined, max: number) =>
  (value ?? "")
    .replace(/[\x00-\x1F\x7F]/g, " ")
    .slice(0, max);

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Missing Authorization header", { status: 401 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });
    const { data: { user }, error: userErr } = await userClient.auth.getUser();
    if (userErr || !user) {
      return new Response("Invalid token", { status: 401 });
    }

    const { household_id, inviter_user_ids } = await req.json();

    if (!household_id || !Array.isArray(inviter_user_ids)) {
      return new Response("Invalid payload", { status: 400 });
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: callerRow, error: callerErr } = await supabase
      .from("users")
      .select("id, household_id, display_name")
      .eq("auth_user_id", user.id)
      .maybeSingle();
    if (callerErr || !callerRow) {
      return new Response("Caller has no profile", { status: 403 });
    }
    if (callerRow.household_id !== household_id) {
      return new Response("Caller is not in target household", { status: 403 });
    }

    const { data: inviters } = await supabase
      .from("users")
      .select("onesignal_player_id")
      .in("id", inviter_user_ids)
      .eq("household_id", callerRow.household_id);

    const playerIds = (inviters ?? [])
      .map((row) => row.onesignal_player_id)
      .filter((id) => typeof id === "string" && id.length > 0);

    if (playerIds.length === 0) {
      return Response.json({ sent: 0 });
    }

    const { data: household } = await supabase
      .from("households")
      .select("name")
      .eq("id", household_id)
      .maybeSingle();

    const appId = Deno.env.get("ONESIGNAL_APP_ID")!;
    const apiKey = Deno.env.get("ONESIGNAL_REST_API_KEY")!;
    const householdName = safeNotificationField(household?.name, 60) ||
      "your household";
    const acceptedUserName =
      safeNotificationField(callerRow.display_name, 80) || "Someone";

    const payload = {
      app_id: appId,
      include_player_ids: playerIds,
      headings: { en: "Invite accepted" },
      contents: {
        en: `${acceptedUserName} accepted your invite to ${householdName}.`,
      },
    };

    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        Authorization: `Basic ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const text = await response.text();
      return new Response(text, { status: 500 });
    }

    return Response.json({ sent: playerIds.length });
  } catch (error) {
    return new Response(String(error), { status: 500 });
  }
});
