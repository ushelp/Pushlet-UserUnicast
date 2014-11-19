# pushlet-UserUnicast 使用手册

---------------

pushlet-UserUnicast 是一个基于pushlet修改扩展之后的`JAVA comet`实现框架。主要扩展实了`unicast`点播推送功能。

> pushlet中的 `unicast` 方法可以实现向指定会话（`SessionID`）推送数据，将数据推送到指定用户，可以由于该 `SessionID` 是随机生成，无法与用户关联，所以无法根据业务字段（如用户ID，用户名）等推送给指定用户。

**核心实现特点：**

- 可以通过用户标识（用户名，主键ID等字符标识均可）向指定用户直接推送消息
- 支持用户多连接的推送和控制：`all`, `first`, `last` 三种类型切换
- 支持中文，使用 `Event` 进行`setField()`时无需转换字符编码
- 简单易用

**说明：**

- 阅读本文档、使用 pushlet-UserUnicast，需要掌握 pushlet 基础，了解 pushlet unicast 的不足 

- 本文档仅包括：如何利用  pushlet-UserUnicast 实现对指定用户点播数据
 
- 本文档不包括：pushlet的介绍、pushlet使用方法、pushlet的API。如需了解，请查阅其他文档。

**注意：**

- 由于推送机制和技术本身的限制，`first`和`last`推送并非是绝对精确的。这是因为：用户断开后，并不能立即检测到并从队列移除用户（有一定时间差），所以如果在某个用户断开连接后，立即进行`first`或`last`推送，可能会推送给已断开的用户。但在时间差允许范围内是安全的，而`all`方式推送时绝对安全的。

##  pushlet-userunicast API：

### 客户端：
- `PL.userId = "userId"`：
使用`PL.userId`属性指定客户端的字符串标识，服务器端根据此标识推送数据到该客户端。在 `PL._init();` 后使用。例如：
```JS
  PL._init();
  PL.userId="JAY";
```

### 服务端：

- `Dispatcher.getInstance().unicastUserId(Event, userId); `：推送数据到指定用户标识的客户端。
  - `Event`： 发布的事件对象和数据
  - `userId`： 用户标识，对应客户端指定的  `PL.userId`
例如：
```JAVA
  String userId="JAY";
 //unicastUserId 推送给指定用户
  Dispatcher.getInstance().unicastUserId(event, userId); 
```

- `Dispatcher.getInstance().unicastUserId(Event, userId, unicastType); `：按照unicastType指定的用户多连接推送类型，推送数据到指定用户标识的客户端。
  - `Event`： 发布的事件对象和数据
  - `userId`： 用户标识，对应客户端指定的  `PL.userId`
  - `unicastType`： 用户多连接推送类型，可选值为 `all`, `first`, `last`（作用参见：用户多连接配置参数）。可使用常量表示：`Sys.USERUNICAST_ALL`, `Sys.USERUNICAST_First`, `Sys.USERUNICAST_Last`
例如：
```JAVA
  String userId="JAY";
 //unicastUserId 推送给指定用户的所有连接
  Dispatcher.getInstance().unicastUserId(event, userId, "all"); 
```

### 用户多连接配置参数：

当多个客户端连接同时使用相同`PL.userId`用户标识时，可以通过 `unicast.type` 参数用户多连接推送类型，`unicastUserId(Event, userId)`方法会使用该值作为用户多连接推送方式。

在 `pushlet.properties` 中可以配置 `unicast.type` 参数，可选值为：
- `all`： 默认值，同一个用户存在多个客户端连接时，向全部客户端连接都推送消息。
- `first`： 仅向最先请求连接的客户端推送消息，后连接的客户端无法接收到消息（当没有其他同名用户连接时，才加入推送，已有用户连接，后连接用户不推送）。
- `last`： 仅向最后请求连接的客户端推消息。
	


## pushlet-userunicast 用户推送使用步骤和示例：

1. 为项目引入lib下的jar包：
**pushlet-userunicast.jar**
**log4j.jar**

2. 在 `src` 或 `WEB-INF` 中加入resource下的配置文件：
**log4j.properties**
**pushlet.properties**
**sources.properties**

3. 在需要订阅事件的 Web 项目中加入client下的客户端JS文件：
**ajax-pushlet-client.js**

4. 在 `web.xml` 配置 `pushlet` 核心Servlet控制器
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

5. 客户端订阅接收消息 index.jsp
使用`PL.userId`属性指定客户端的字符串标识，服务器端根据此标识推送数据到该客户端
   ```JS
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
        <title>用户接收消息页面</title>

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
        		document.getElementById("status").innerHTML="连接服务器成功！";
        	}

         </script>
    </head>
    
    <body>
        <h2 id="status" style="color: red">请等待，连接服务器中....</h2>
    	<div id="msg"></div>
    	<br />
    	<br />
    	<br />
    	<a href="publish.jsp" target="_blank">后台推送消息页面</a>
    </body>
    </html>
  ```

6. 服务器端推送数据的测试Servlet
使用 `Dispatcher.getInstance().unicastUserId(Event, userId用户标识); ` 推送数据到指定用户标识的客户端，`userId用户标识` 对应  `PL.userId` 。
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
    		// 推送消息
    		String msg=req.getParameter("msg");
    //		String userId="JAY";
    		// 推送用户
    		String userId=req.getParameter("userId");
    		// 用户多连接推送方式
    		String type=req.getParameter("type");
    		
    		// 事件对象和数据
    		Event event = Event.createDataEvent("/push/hello");
    		event.setField("msg", msg); //中文无需转换为ISO-8859-1
    		
    		// 根据pushlet.properties的unicast.type参数值推送给指定用户
    //	    Dispatcher.getInstance().unicastUserId(event,userId);  
    		
    		 // 根据指定type类型推送给指定用户
    	    Dispatcher.getInstance().unicastUserId(event, userId, type); 
    	}
    }
  ```
web.xml的servlet配置
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

7. 调用Servlet，发布推送消息的页面 publish.jsp
  ```HTML
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
         <title>发布推送消息</title>
    </head>
    
    <body>
    	<h1>发布需要推送的信息：</h1>
    	<form action="servlet/MsgPushServlet" method="post" target="pushFrame">
    		<p>
    			推送的用户userId：<input type="text" name="userId" value="JAY" />
    		</p>
    		<p>
    			推送内容：<input type="text" name="msg" >
    		</p>
    		<p>
    			推送类型： 
    			<input type="radio" name="type" id="all" value="all" checked="checked">
    			<label for="all">ALL（所有连接）</label>
    			 <input type="radio" name="type" id="first" value="first">
    			 <label for="first">FIRST （第一个连接）</label>
    			 <input type="radio" name="type" id="last" value="last">
    			 <label for="last">LAST （最后一个连接）</label>
    		</p>
    		<input type="submit" value="发布推送">
    	</form>
    	
    	<iframe name="pushFrame" style="display: none;"></iframe>
    </body>
    </html>
  ```




## 结束



如果您有更好意见，建议或想法，请联系我。


联系、反馈、定制、培训 Email：<inthinkcolor@gmail.com>