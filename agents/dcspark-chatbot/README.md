<h1 align="center">
  dcSpark Chatbot
</h1>

Basic Chatbot implemented as a Gall agent.

The agent subscribes to incoming messages, i.e. `graph-store/updates`, and reads the message text. 
If the message is equal to one of the triggers, it builds a `%graph-store` node and pokes `%graph-store` with it.

## Triggers and Responses

`!dcbot website`    -> The dcSpark Website

`!dcbot visor`      -> The Urbit Visor Website

`!dcbot dashboard`  -> The Urbit Dashboard Website

`!dcbot flint`      -> The Flint Wallet Website

`!dcbot milkomeda`  -> The Milkomeda Website

`!dcbot discord`    -> The dcSpark Discord

`!dcbot snippets`   -> The dcSpark Hoon Snippets Github Repo

`!dcbot sourcecode` -> This repo

`.` -> `ack`
