--------------------------------------------------------------------------------------
**Author:**        R. Paul Wiegand  
**Date Created:**  2018-11-26  
**Modified By:**   Austin Davis, 2023-12-06
--------------------------------------------------------------------------------------

# Installation
This package contains three two to start a Jupyter Notebook (JN) server:
1. **vpn.sh**: Script to connect to the UCF vpn.
1. **startJupyterServer.sh**: Script to start a Jupyter Labs server.

You should the following bookmarklet to your browser:
```js
javascript:(function() {  
    var cookieMatch = document.cookie.match(/webvpn=(.*?);/);  
    if (cookieMatch && cookieMatch[1]) {    
        navigator.clipboard.writeText(cookieMatch[1]);    
        alert(cookieMatch[1]);  
    } else {    
        alert(%27No matching cookie found%27);  
    }})();
```

# Usage

1. Login to https://secure.vpn.ucf.edu/ 
1. Use the bookmarklet from above to get your cookie. It should be automatically copied to your clipboard.
1. Connect to the UCF VPN by running: `sudo ./vpn.sh`
1. When prompted paste in your cookie from step 2 above.
1. Follow the on-screen instructions.
