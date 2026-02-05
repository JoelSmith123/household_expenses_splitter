import { createClient } from "https://esm.sh/@supabase/supabase-js@2.48.1";

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Missing Authorization header", { status: 401 });
    }

    const {
      household_id,
      inviter_user_ids,
      invites,
    } = await req.json();

    if (!household_id || !Array.isArray(invites)) {
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
      .select("display_name")
      .in("id", inviter_user_ids ?? []);

    const inviterNames = (inviters ?? [])
      .map((row) => row.display_name || "Someone")
      .filter(Boolean);

    const inviterText =
      inviterNames.length === 0
        ? "Someone"
        : inviterNames.length === 1
        ? inviterNames[0]
        : inviterNames.length === 2
        ? `${inviterNames[0]} and ${inviterNames[1]}`
        : `${inviterNames.slice(0, -1).join(", ")} and ${
            inviterNames[inviterNames.length - 1]
          }`;

    const householdName = household?.name ?? "their household";

    const inviteRows = invites.map((invite: any) => ({
      household_id,
      invited_phone_e164: invite.phone_e164,
      inviter_user_ids: inviter_user_ids ?? [],
      status: "pending",
    }));

    await supabase.from("household_invites").upsert(inviteRows, {
      onConflict: "household_id,invited_phone_e164",
    });

    const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID")!;
    const authToken = Deno.env.get("TWILIO_AUTH_TOKEN")!;
    const fromNumber = Deno.env.get("TWILIO_FROM_NUMBER")!;
    const url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;

    let sentCount = 0;
    for (const invite of invites) {
      const body = new URLSearchParams({
        From: fromNumber,
        To: invite.phone_e164,
        Body: `${inviterText} invited you to join ${householdName} on Tally. Download the app to join.`,
      });

      const res = await fetch(url, {
        method: "POST",
        headers: {
          Authorization: "Basic " + btoa(`${accountSid}:${authToken}`),
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body,
      });

      if (res.ok) {
        sentCount += 1;
      }
    }

    return Response.json({ sent: sentCount });
  } catch (error) {
    return new Response(String(error), { status: 500 });
  }
});
