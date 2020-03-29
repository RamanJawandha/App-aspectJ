/*
SOEN 6441 (Winter 2020) 
Submitted to: Dr. Constantinos Constantinides
Submitted by:
			Aayush Lamichhane (40091493)
			Ramandeep Kaur (40084201)
			Gurvinder Singh Bhai Ka (40070767)
			Guoxue Yang (40130562)
 */

import java.util.ArrayList;

public privileged aspect Authentication {
	
	private static ArrayList<String> Server.blackList = new ArrayList<String>(); 
	
	private void Server.blackListDomain(Client c) {
		blackList.add(c.getAddress());
	}
	
	private boolean Server.isBlackListed(Client c){
		return blackList.contains(c.getAddress());
	}
	
	pointcut chckDomain (Server s, Client c) : (call (* Server.*(..)) 
												&& this(c)
												&& target(s));
	
	pointcut validateReq(Server s, Client c) : (call (void Server.getClients()) 
												&& target(s)
												&& this(c)) || 
											   (call (void Server.getClients2()) 
												&& target(s) 
												&& this(c));
	
	Object around(Server s, Client c) : chckDomain(s, c) {
		if (s.isBlackListed(c) && s.isClient(c)) {
			s.detach(c);
			System.out.println("Connection broken between "+ c.toString() + " and " + s.toString() + ".");
			s.getClients2();
		}
		else if (s.isBlackListed(c)){
			//Do not accommodate the request
		}
		else {
			proceed(s, c);
		}
		return null;
	}
	
	void around(Server s, Client c) : validateReq(s, c) {
		System.out.println("WARNING >>> Suspicious call from " + c.getAddress() + " : " +thisJoinPoint +"\n");
		c.disconnect(s);
		s.blackListDomain(c);
	}
}
