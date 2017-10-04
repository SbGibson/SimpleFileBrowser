# SimpleFileBrowser
Simple web browser for directories and files.

This is the most simple ASP.Net web file browser possible. It's purpose is to enable to embed in an existing website a file browser without the need to recompile source code, add config keys and/or external reference.

## Usage
The project is composed of two files:

browser.ascx: the core of the browser, it handles all the logic and the dynamic layout things.
browse.aspx: a simple aspx page that host the usercontrol.

### Easiest
Copy both ascx and aspx file in your web folder and navigate to http://yourhostname/yourwebapp/browse.aspx, you will see the list of files and directories from the root of your site and on.

### Easy
Copy ascx file in your web folder and embed it inside your custom aspx page. Navigate to your page and you will see the list of files and directories from the root of your site and on.

### Pro
You can customize the behavior of the browser changing the value of properties inside the ascx code directly or overriding values in the .aspx file (or any other way you integrate the browser in your website ex.: a macro in Umbraco CMS).
The properties are pretty self-explanatory.

## License
Feel free to copy and modify the code at your pleasure. Leaving the original header will be appreciated. If you make any change that can increase Simple File Browser effectiveness please share with us.

## Support
For any question or bug please you can use Issues, I will look at them as soon as possible.
