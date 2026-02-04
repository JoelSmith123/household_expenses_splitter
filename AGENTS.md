## Structure

The architecture must stay scalable and centralized. 

Each "page" is structured as its own Widget in a separate .dart file, which returns the 'Consumer<AppState>' if access to state is needed. 

Avoid duplication: always check for existing functionality when implementing new functionality. For example, don't create a new login screen if one already exists. 

## State

State is managed centrally in a single lib/providers/app_state.dart file, containing an AppState class which extends a ChangeNotifier. There are some exceptions to this when needed, such as some of the auth-related signin widgets. 

## Style

Styles (such as fonts or colors) should be stored centrally, to improve future scalability and ease of changing the styles later on. 

Always use Cupertino styling. Do not use Material unless there is no Cupertino alternative, and then in that case, get permission first. 

## Database

In the MCP-connected Supabase, use its schema and datatable for figuring out functionality that utilizes that server. 