// Market bloc shims removed.
//
// Demo now uses real production blocs for all read/GET operations:
//   - Sports categories, competitions, events, inplay counts
//   - Odds / bookmaker / fancy (HTTP fetch + live SignalR feed)
//   - Casino game listings
//   - Scoreboard
//
// Only account, orders, funds, auth, and favourites blocs are overridden
// in DemoBlocScope so that no user data is persisted on the real server.
