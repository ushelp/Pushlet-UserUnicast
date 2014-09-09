<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<%=basePath%>">

<title>发布推送消息</title>

<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
<meta http-equiv="description" content="This is my page">
<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
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
