# pushlet-UserUnicast Manual

---------------

pushlet-UserUnicast is based on a modified extension `JAVA comet` pushlet after implementation framework. Major expansion of the `unicast` real demand push function.

> The method `unicast` pushlet can push data to the specified session (` SessionID`), the data is pushed to the specified user, since the `SessionID` can be randomly generated, can not be associated with a user, it is not according to the service field (such as the user ID, user name) and so pushed to the specified user.

**Core implementation features:**

- Push messages directly to a specified user by user ID (user name, primary key ID and other characters can be identified)
- Supports multi-user connections push and control: `all`,` first`, `last` three types of switching
- use `Event` be` setField () ` no need to convert the character encoding to support other character, 
- Easy to use

**Explanation:**

- Read this document, use pushlet-UserUnicast, need to master pushlet basis of lack of understanding pushlet unicast

- This document includes only: How to use pushlet-UserUnicast achieve the specified user demand for data
 
- This document does not include: Introduction pushlet's, pushlet use, pushlet the API. For more information, please consult other documentation.

**Note:**

- Due to restrictions push mechanism and the technology itself, `first` and` last` push is not absolutely accurate. This is because: After the user disconnects, and can not immediately detect and remove users from the queue (with a certain time lag), so if a user is disconnected immediately `first` or` last` push, might pushed to disconnected users. But in the time difference within the allowable range is safe, but `all` way when push absolutely safe.

##  pushlet-userunicast API: 

### Client:
- `PL.userId = "userId"`: 
Use `PL.userId` attribute specifies the string that identifies the client, the server-side push based on this data to identify the client. Use the `; in` PL._init (). Such as: 
```JS
  PL._init();
  PL.userId="JAY";
```

### Server:

- `Dispatcher.getInstance().unicastUserId(Event, userId); `: Push data to the specified user ID client.
  - `Event`: Release event object and data
  - `userId`: User ID specified in the corresponding client `PL.userId`
For example:
```JAVA
  String userId="JAY";
 //unicastUserId Pushed to the specified user
  Dispatcher.getInstance().unicastUserId(event, userId); 
```

- `Dispatcher.getInstance().unicastUserId(Event, userId, unicastType); `: In accordance with the specified user multiple connections unicastType push type, push data to the specified user ID client.
  - `Event`: Event objects and data release
  - `userId`: User ID specified in the corresponding client  `PL.userId`
  - `unicastType`: Multi-user connections push type, optional value `all`,` first`, `last`(See Role: Multi-user connections configuration parameter). You can use constants, said: `Sys.USERUNICAST_ALL`, `Sys.USERUNICAST_First`, `Sys.USERUNICAST_Last`
For example:
```JAVA
  String userId="JAY";
 //unicastUserId Push all connections to the specified user
  Dispatcher.getInstance().unicastUserId(event, userId, "all"); 
```

### Multi-user connection configuration parameters:

When multiple clients to connect simultaneously use the same user ID `PL.userId` can be more connected to the push type parameters by` unicast.type` user, `unicastUserId (Event, userId)` method uses multiple connections that value as the user push the way.

In `pushlet.properties` can configure` unicast.type` parameters, optional value:
- `all`:  The default value, the presence of the same user multiple client connections, the client connections to all push messages.
- `first`:  Only to the first client requests a connection push message, after connecting clients can not receive the message (when no other users connected to the same name, only to join the push, existing user connections, after connecting the user does not push).
- `last`:  Only client connection requests to the last push message.
	


## pushlet-userunicast Users push the use of steps and examples: 

1. Jar package introduced for the project under lib: 
**pushlet-userunicast.jar**
**log4j.jar**

2. Join the configuration file resource under the `src` or` WEB-INF` in:
**log4j.properties**
**pushlet.properties**
**sources.properties**

3. Need to subscribe to an event added to the Web project client under the client JS file:
**ajax-pushlet-client.js**

4. In `web.xml` core Servlet controller configuration` pushlet`
  ```XML
  <servlet>
        <servlet-name>pushlet</servlet-name>
        <servlet-class>
            nl.justobjects.pushlet.servlet.Pushlet 
        </servlet-class>
        <load-on-startup>1</load-on-startup>
  </servlet>
  <servlet-mapping>
        <servlet-name>pushlet</servlet-name>
        <url-pattern>/pushlet.srv</url-pattern>
  </servlet-mapping>
  ```

5. Clients subscribe to receive messages index.jsp
Use `PL.userId` attribute specifies the string that identifies the client, server-side push data in accordance with this identity to the client
   ```JS
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
        <title>Users receive a message page</title>

        <script type="text/javascript" src="js/ajax-pushlet-client.js"></script>
        <script type="text/javascript">
        	PL._init();
        	PL.userId = "JAY";
        	PL.joinListen('/push/hello');
        	function onData(event) {
        		//console.info(event.get("msg"));
        		document.getElementById("msg").innerHTML = document
        				.getElementById("msg").innerHTML
        				+ event.get("msg") + "<br/>";
        	}

        	window.onConnected=function(){
        		document.getElementById("status").innerHTML="Server Connected!";
        	}

         </script>
    </head>
    
    <body>
        <h2 id="status" style="color: red">Please wait, Server Connecting....</h2>
    	<div id="msg"></div>
    	<br />
    	<br />
    	<br />
    	<a href="publish.jsp" target="_blank">Push back page news</a>
    </body>
    </html>
  ```

6. Servlet server-side push test data
Use `Dispatcher.getInstance () unicastUserId (Event, userId user ID);` push data to the specified client user ID, `userId` user ID corresponding `PL.userId`.
  ```JAVA
    package servlet;

    import java.io.IOException;
    
    import javax.servlet.ServletException;
    import javax.servlet.http.HttpServlet;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    
    import nl.justobjects.pushlet.core.Dispatcher;
    import nl.justobjects.pushlet.core.Event;
    
    public class MsgPushServlet extends HttpServlet {
    
    	@Override
    	protected void service(HttpServletRequest req, HttpServletResponse resp)
    			throws ServletException, IOException {
    		req.setCharacterEncoding("utf-8");
    		// Push message
    		String msg=req.getParameter("msg");
    //		String userId="JAY";
    		// Push users
    		String userId=req.getParameter("userId");
    		// Push-user multi-way connection
    		String type=req.getParameter("type");
    		
    		// Event objects and data
    		Event event = Event.createDataEvent("/push/hello");
    		event.setField("msg", msg); //Chinese do not need to be converted to ISO-8859-1
    		
    		// According unicast.type push parameter values ​​to the specified user pushlet.properties
    //	    Dispatcher.getInstance().unicastUserId(event,userId);  
    		
    		 // Pushed to the specified user from the specified type type
    	    Dispatcher.getInstance().unicastUserId(event, userId, type); 
    	}
    }
  ```
The servlet web.xml configuration
  ```XML
  <servlet>
        <servlet-name>MsgPushServlet</servlet-name>
        <servlet-class>servlet.MsgPushServlet</servlet-class>
  </servlet>

  <servlet-mapping>
        <servlet-name>MsgPushServlet</servlet-name>
        <url-pattern>/servlet/MsgPushServlet</url-pattern>
  </servlet-mapping>
  ```

7. Call Servlet, publish pages publish.jsp push message
  ```HTML
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
         <title>Published push message</title>
    </head>
    
    <body>
    	<h1>Published need to push the message:</h1>
    	<form action="servlet/MsgPushServlet" method="post" target="pushFrame">
    		<p>
    			push userId: <input type="text" name="userId" value="JAY" />
    		</p>
    		<p>
    			push message: <input type="text" name="msg" >
    		</p>
    		<p>
    			push type:  
    			<input type="radio" name="type" id="all" value="all" checked="checked">
    			<label for="all">ALL（all connection）</label>
    			 <input type="radio" name="type" id="first" value="first">
    			 <label for="first">FIRST （first connection））</label>
    			 <input type="radio" name="type" id="last" value="last">
    			 <label for="last">LAST （last connection））</label>
    		</p>
    		<input type="submit" value="push">
    	</form>
    	
    	<iframe name="pushFrame" style="display: none;"></iframe>
    </body>
    </html>
  ```




## End

[Demo online](http://www.easyproject.cn/easyunicast/en/index.jsp#demo 'Demo online')

[Comments](http://www.easyproject.cn/easyunicast/en/index.jsp#about 'Comments')

If you have more comments, suggestions or ideas, please contact me.


Contact, feedback, customization, training Email: <inthinkcolor@gmail.com>

<p>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_blank">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="business" value="inthinkcolor@gmail.com">
<input type="hidden" name="item_name" value="EasyProject development Donation">
<input type="hidden" name="no_note" value="1">
<input type="hidden" name="tax" value="0">
<input type="image" src="http://www.easyproject.cn/images/paypaldonation5.jpg"  title="PayPal donation"  border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
</form>
</P>

[http://www.easyproject.cn](http://www.easyproject.cn "EasyProject Home")