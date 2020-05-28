import java.io.UnsupportedEncodingException;
import java.net.URLDecoder; 
import java.net.URLEncoder;

public class Main {
	public static void main(String[] args) {

		try {   
			String url = "/ac-common/common/getCurTimeStamp?id=123&name=xiao.ming&address=美国"; 
    		/**
    		 1. 保持不变：
    		 [a-z][A-Z][0-9]
    		 .-*_
			
			 2. 空格转 "+"	
    		 " " -> "+"

			 3. 其他字符 UTF-8 编码后的字节加上前缀 "%"

			*/

			 // url = "abcABC0123.-*_";
			 // url = " ";
			 url = "/ac-common/common/user?age=12&birdate=2019-05-11&name=xiaoming&nonce=C9F15CBFF4AC4A6CB54DF51ABF4B5B44&timestamp=1525872629832";
			 String encodeURL = URLEncoder.encode( url, "UTF-8" );   
			 System.out.println(encodeURL);  


			} catch (UnsupportedEncodingException e) {   				

			}   

		}
	}