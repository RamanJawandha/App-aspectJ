/*
SOEN 6441 (Winter 2020) 
Submitted to: Dr. Constantinos Constantinides
Submitted by:
			Aayush Lamichhane (40091493)
			Ramandeep Kaur (40084201)
			Gurvinder Singh Bhai Ka (40070767)
			Guoxue Yang (40130562)
*/

public privileged aspect Logging {	
	
	public void Server.getClients2() {
		System.out.print("Clients logged in: " + clients + "\n\n\n");
	}
	
	pointcut reqConn(Server s, Client c) : call (void Client.connect(Server)) 
											&& args(s) 
											&& target(c);
	
	pointcut disConn(Server s, Client c) : call (void Client.disconnect(Server)) 
											&& args(s) 
											&& target(c);
		
	void around(Server s, Client c) : reqConn(s, c) {
		if (!s.isClient(c)) {
			System.out.println("CONNECTION REQUEST >>> "+ c.toString() + " requests connection to " + s.toString() + ".\n");
			if (!s.isBlackListed(c)) {
				proceed(s, c);
				System.out.println("Connection established between "+ c.toString() + " and " + s.toString() + ".");
				s.getClients2();
			}
		}
	}
	
	void around(Server s, Client c) : disConn(s, c){
		if (s.isClient(c)) {
			proceed(s, c);
			System.out.println("Connection broken between "+ c.toString() + " and " + s.toString() + ".");
			s.getClients2();
		}
	}
}
