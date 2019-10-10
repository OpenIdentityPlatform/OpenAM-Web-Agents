## OpenAM Web Policy Agents
[![Latest release](https://img.shields.io/github/release/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/releases)
[![Build Status](https://travis-ci.org/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://travis-ci.org/OpenIdentityPlatform/OpenAM-Web-Agents)
[![Issues](https://img.shields.io/github/issues/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/issues)
[![Last commit](https://img.shields.io/github/last-commit/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/commits/master)
[![License](https://img.shields.io/badge/license-CDDL-blue.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/blob/master/LICENSE.md)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/OpenIdentityPlatform/OpenAM)
[![Top language](https://img.shields.io/github/languages/top/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents)
[![Code size in bytes](https://img.shields.io/github/languages/code-size/OpenIdentityPlatform/OpenAM-Web-Agents.svg)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents)

OpenAM Web Policy Agents is an OpenAM add-on component that functions as a Policy Enforcement Point (PEP) for applications deployed on Apache HTTP Server ("httpd"). The policy agent protects web-based applications and implements single sign-on (SSO) capabilities for the applications deployed in the container.

## License
This project is licensed under the [Common Development and Distribution License (CDDL)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/blob/master/LICENSE.md). 

## Downloads 
* [OpenAM Web Policy Agent (Apache 2.2 Linux x64 ZIP)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/releases)
* [OpenAM Web Policy Agent (Apache 2.4 Linux x64 ZIP)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/releases)
* [OpenAM Web Policy Agent (IIS  Windows x32/x64 ZIP)](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/releases)

## How-to build
```bash
sudo apt-get install -qq -y libpcre3-dev libbz2-dev
git clone --recursive  https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents.git
cd OpenAM-Web-Agents
make apache22zip && ls build/*.zip
make apachezip && ls build/*.zip
```

## Support and Mailing List Information
* OpenAM Web Policy Agent Community Wiki: https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/wiki
* OpenAM Web Policy Agent Community Mailing List: open-identity-platform-openam@googlegroups.com
* OpenAM Web Policy Agent Community Archive: https://groups.google.com/d/forum/open-identity-platform-openam
* OpenAM Web Policy Agent Community on Gitter: https://gitter.im/OpenIdentityPlatform/OpenAM
* OpenAM Web Policy Agent Commercial support RFP: support@openam.org.ru (English, Russian)

## Contributing
Please, make [Pull request](https://github.com/OpenIdentityPlatform/OpenAM-Web-Agents/pulls)

## Thanks for OpenAM Web Policy Agent
* Sun Access Manager
* Sun OpenSSO
* Oracle OpenSSO
* Forgerock OpenAM
