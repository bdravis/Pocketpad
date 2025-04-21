# PocketPad

PocketPad is a iOS app which allows you to connect your phone to your computer and emulate a range of game controllers. This repository contains both the iOS client and the python cross-platform server.

Currently there are no compiled releases for client or server, so both will need to be run from source. Unfortunately this requires Xcode developer tools on MacOS for compiling the client application, though the server will run on any desktop OS.
### Server Setup Instructions

- Ensure that you are in a python environment
- Run the following command:

```
pip install -r "PocketPad Server/requirements.txt"
```

- To start the server, run the following command:

```
python3 "PocketPad Server/server_app.py"
```

- Click the `Bluetooth Server` button to start the server
- The Bluetooth server should start advertising, if not, sorry :(
### Client Setup Instructions

 - Ensure that your iPhone is in developer mode
 - Ensure that the proper Xcode tools are installed
 - Ensure that the developer is trusted
 - Follow the instructions provided by Xcode after pressing the build button with your phone connected via usb
 - Ensure that the server is running
 - Press `connect` and select your device
 - Press `Open Debug Controller View`
 - Press the buttons to your heart's content
