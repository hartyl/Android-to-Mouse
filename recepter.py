import socket
import pyautogui
import json

def receive_coordinates():
    # Create a socket object
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    ip = socket.gethostbyname(socket.gethostname())
    # Define the host and port
    host = ip  # Localhost
    port = 5329
    
    # Bind the socket to the address
    server_socket.bind((host, port))
    
    print("Server is listening for coordinates...\n\n\n\n\n\n\n\n\n                      Server-ip: " + ip + "\n\n\n")

    move = 0
    s = True
    winx = 200
    winy = 80
    size = 600
    pyautogui.FAILSAFE = False
    pyautogui.PAUSE = 0
    click = False
    xpre = 0
    ypre = 0
    win_size = pyautogui.size()
    march = 0
    p = 1
    connected = False
    
    while True:
        # Receive data from the client
        data, addr = server_socket.recvfrom(128)
        coordinates = data.decode('utf-8')
        print(f"Received coordinates: {coordinates} from {addr}, {winx}, {winy}")
        coordinates = json.loads(coordinates)
        if connected == False:
            if not "hello!" in coordinates:
                connected = True

        if "hello!" in coordinates:
            p = coordinates['hello!']
            print('sending: Cool!')
            str = "Cool!"
            server_socket.sendto(str.encode(), addr)
            connected = True
            continue
        moveToX = coordinates['x'] * size * p
        moveToY = coordinates['y'] * size
        if "s" in coordinates:
            s = coordinates['s']
        else:
            s = 0
        if s > -1:
            pyautogui.moveTo(moveToX + winx, moveToY + winy)
        else:
            march = (march + 1) % 4
            mx = winx
            my = winy
            if march % 2 == 0:
                mx += size * p
            if march < 2:
                my += size
            pyautogui.moveTo( mx, my )
        move -= 1
        if s > 0:
            if click == False:
                pyautogui.mouseDown(button = 'left')
                click = True
        elif s == 0:
            if click == True:
                pyautogui.mouseUp(button = 'left')
                click = False
        else:
            if move < 0:
                xO = moveToX
                yO = moveToY
                win_x_pre = winx
                win_y_pre = winy

            move = 2
            winx = min(max(win_x_pre + moveToX - xO, 0), win_size[0] - size * p)
            winy = min(max(0,win_y_pre + moveToY - yO), win_size[1] - size)
            winx = winx - winx %1
            winy = winy - winy %1

if __name__ == "__main__":
    receive_coordinates()

