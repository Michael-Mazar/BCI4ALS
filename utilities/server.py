
import socketserver
import socket

class MyTCPHandler(socketserver.BaseRequestHandler):
    """
    The request handler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """
    def __init__(self, request, client_address, server, filename) -> None:
        super().__init__(request, client_address, server)
        self.filename = filename

    def handle(self):
        # self.request is the TCP socket connected to the client
        print("Handling a new request...")
        self.data = self.request.recv(1024).strip()
        print("{} wrote:".format(self.client_address[0]))
        print(self.data)
        # just send back the same data, but upper-cased
        self.request.sendall(bytes(self.data.upper()))
        print("Sent response")
        with open(self.filename, "rb") as f:
            f.writelines(self.data)


def handle(request):
        # self.request is the TCP socket connected to the client
        print("Handling a new request...")
        data = conn.recv(1024).strip()
        print(data)
        # just send back the same data, but upper-cased
        conn.sendall(bytes(data.upper()))
        print("Sent response")
        # with open(self.filename, "rb") as f:
        #     f.writelines(self.data)

def stop_signal(data):
    return str(data, "ascii")=="stop"

if __name__ == "__main__":
    HOST = 'localhost'       # Symbolic name meaning all available interfaces
    PORT = 50007              # Arbitrary non-privileged port
    is_running = True
    

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST, PORT))
        s.listen()
        conn, addr = s.accept()
        with conn:
            print("Connected by {}".format(addr))

            while is_running:
                try:
                    print("Waiting for a new message...")
                    data = conn.recv(1024)
                    print(data)

                    if stop_signal(data) or not(data):
                        is_running = False
                        conn.sendall(bytes("Got stop signal or empty request,\n closing connection...", "ascii"))
                        print("Closing connection...")
                        break
                    else:
                        # just send back the same data, but upper-cased
                        conn.sendall(bytes(data.upper()))
                        print("Sent response")
                    
                except _ as ex:
                    print("Exception thrown while handling requests: {}".format(ex))
                
            

    # Create the server, binding to localhost on port 9999
    # with socketserver.TCPServer((HOST, PORT), MyTCPHandler, bind_and_activate=True) as server:
    #     # Activate the server; this will keep running until you
    #     # interrupt the program with Ctrl-C
    #     while is_running and i < 5:
    #         try:
    #             response = server.handle_request()
    #             i += 1
    #             print(response)
    #             # server.serve_forever()
    #         except _ as e:
    #             print("Exception thrown while handling a request")
        



