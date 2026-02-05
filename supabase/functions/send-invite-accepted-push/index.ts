import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Missing Authorization header", { status: 401 });
    }

    const { household_id, inviter_user_ids, accepted_user_name } =
      await req.json();

    if (!household_id || !Array.isArray(inviter_user_ids)) {
      return new Response("Invalid payload", { status: 400 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: household } = await supabase
      .from("households")
      .select("name")
      .eq("id", household_id)
      .maybeSingle();

    const { data: inviters } = await supabase
      .from("users")
      .select("onesignal_player_id")
      .in("id", inviter_user_ids);

    const playerIds = (inviters ?? [])
      .map((row) => row.onesignal_player_id)
      .filter((id) => typeof id === "string" && id.length > 0);

    if (playerIds.length === 0) {
      return Response.json({ sent: 0 });
    }

    const appId = Deno.env.get("ONESIGNAL_APP_ID")!;
    const apiKey = Deno.env.get("ONESIGNAL_REST_API_KEY")!;
    const householdName = household?.name ?? "your household";

    const payload = {
      app_id: appId,
      include_player_ids: playerIds,
      headings: { en: "Invite accepted" },
      contents: {
        en: `${accepted_user_name ?? "Someone"} accepted your invite to ${householdName}.`,
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
