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
