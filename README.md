# Distrobox

This repository holds all my custom [Distrobox](https://distrobox.it/) manifest files which I use to get apps
running on [bluefin-dx](https://projectbluefin.io/) where an official [Flatpak](https://flathub.org/)
version is missing. There might be community driven Flatpaks out there for these apps
but I really think Flatpaks for certain apps should be built by the application owners and
not by the community.

## Base Images

Since my computers are running [universal blue](https://universal-blue.org/) I rely on the
[uBlue OS Toolbox](https://github.com/ublue-os/toolboxes) images. A big shout out
to all [contributors](https://github.com/ublue-os/toolboxes/graphs/contributors)! Thank you!

## Applications

Whenever possible I try to package the applications from the same "vendor" in a single
distrobox.

The following distroboxes manifestos are available:

| Manifest                                  | Description                                           | Install                                                       |
| ----------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------- |
| [Proton Apps](./protonapps/distrobox.ini) | A selection of [Proton Apps](https://protonapps.com/) | `distrobox assemble create --file ./protonapps/distrobox.ini` |
