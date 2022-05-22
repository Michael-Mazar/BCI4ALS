import socket

encoding = "ascii"

def client(ip, port, message):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((ip, port))
        sock.sendall(bytes(message, encoding))
        response = str(sock.recv(1024), encoding)
        print("Received: {}".format(response))




def create_client():
    HOST = "localhost"
    PORT = 50007
    timeout = 10 # in seconds
    return socket.create_connection((HOST, PORT), timeout=timeout)

def request_and_resp(sock, req_msg):
    sock.sendall(bytes(req_msg, encoding))
    print("RESPONSE: {}".format(str(sock.recv(1024), encoding)))

# In [28]: s.connect(("localhost", 50007))

# In [29]: s.sendall(bytes("hello world", "ascii"))

# In [30]: s.sendall(bytes("hello world", "ascii"))

# In [31]: s.sendall(bytes("hello world", "ascii"))

# In [32]: response = str(sock.recv(1024), "ascii")