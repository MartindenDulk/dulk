# _dulk - an Perl IRC bot_
Description: The idea was to create an IRC Bot from scratch with Perl. dulk uses IO::Socket as the fundament for the connection and the plan is to create everything around it ourselves.

## Todo
- Module for authing the bot with various IRC network services
- Create dynamic module loading
-- Make it so that a small help text can be stored and viewed with an command/web interface
-- Hook public subroutine to main public. Once the socket received a message distribute the message amongst the registered plugins
- Create config structure
-- Retrieve basic config settings from it (username/server)
- Enable multi-server support

## About
Project was started by Martin den Dulk. For more info or questions hit me up at irc.bracketnet.org / #nl / User: Mojito

## License
Code released under [the MIT license](LICENSE).
