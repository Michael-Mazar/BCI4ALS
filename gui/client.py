import socket

HOST="localhost"
PORT=12345

START_CUE=b"START\n"
STOP_CUE=b"STOP\n"

TIMEOUT=60 * 10 # in seconds

class Client:
    def __init__(self,host=HOST,port=PORT):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.is_connected = False
        self.server_addr = host
        self.server_port = port
        
    def connect(self):
        if not self.is_connected:
            self.sock.settimeout(TIMEOUT)
            self.sock.connect((self.server_addr, self.server_port))
            self.is_connected = True
            print("Successfully connected to {}:{}".format(self.server_addr, self.server_port))
    
    def get_prediction_data(self):
        self.sock.settimeout(TIMEOUT)
        self.sock.sendall(START_CUE)
        
        self.sock.settimeout(TIMEOUT)
        response = self.sock.recv(1024)
        
        return int(response)

    def close_connection(self):
        if self.is_connected:
            self.sock.close()
            print("Connection to server is closed")

            self.is_connected = False
            # Create a new socket for the next time we want to connect to the server
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        else:
            print("Connection is already closed")

