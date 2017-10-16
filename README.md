# Skygear Chat iOS Demo

This iOS Demo is written in Swift and is powered by [Skygear](https://skygear.io) and [Skygear Chat](https://skygear.io/chat). 

## Skygear Introduction
[Skygear](https://github.com/skygeario) is an open source back-end-as-a-service that speeds up app development. [SkyChat](https://github.com/SkygearIO/chat) is a module under Skygear and has all the messaging features a chat app usually needs.

## Screenshot

## Features Demonstrated

### User athentication
- [x] User sign up and login 
- [ ] User logout

### Conversation creation
- [x] Create 1 to 1 conversation
- [x] Create Group conversation

### Conversation list
- [x] Get all conversations of a users
- [x] Show unread counts of a conversation

### Conversation view (from UI kit)
- [x] Load messages from conversations (chat history)
- [x] Send text messages
- [x] Message receipt status
- [x] Typing indicator
- [ ] Send photo messages
- [ ] Send voice messages
- [ ] Edit messages
- [ ] Delete messages

### Conversation setting
- [ ] Leave Conversations
- [ ] Add Users to Conversations
- [ ] Remove Users from Conversations
- [ ] Add admin
- [ ] Remove admin

### Notification
- [ ] Push notification for new messages
- [ ] Mute conversation's notification

## Installation Guide

1. Clone the project

	```
	git clone git@github.com:tszkanlo/SkygearChat-iOS-Demo.git
	```
	If you are using Xcode 8, please clone the `xcode-8` branch.
	
	```
	git clone -b xcode-8 git@github.com:tszkanlo/SkygearChat-iOS-Demo.git
	```
2. Install dependancies

	```
	pod install
	```
3. Open `Swift Chat Demo 2.xcworkspace`
