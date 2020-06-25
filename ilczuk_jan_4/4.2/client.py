import sys
import glob
sys.path.append('gen-py')

from topFreezer import TopFreezer
from compactFridge import CompactFridge
from securityCamera import SecurityCamera
from nightCamera import NightCamera
from listDevices import ListDevices
from device.ttypes import Power
from fridge.ttypes import Status
from fridge.ttypes import BadTemperature
from securityCamera.ttypes import RotateException
from securityCamera.ttypes import ZoomException
from securityCamera.ttypes import Zoom
from securityCamera.ttypes import Rotate
from nightCamera.ttypes import NightvisionStatus
from compactFridge.ttypes import BadColor
from compactFridge.ttypes import Color



from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.protocol import TMultiplexedProtocol



def main():
    # Make socket
    transport = TSocket.TSocket('localhost', 9090)

    # Buffering is critical. Raw sockets are very slow
    transport = TTransport.TBufferedTransport(transport)

    # Wrap in a protocol
    protocol = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "topFreezer")

    # Create a client to use the protocol encoder
    client = TopFreezer.Client(protocol)

    protocol2 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "compactFridge")

    # Create a client to use the protocol encoder
    client2 = CompactFridge.Client(protocol2)

    protocol3 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "securityCamera")
    client3 = SecurityCamera.Client(protocol3)

    protocol4 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "nightCamera")
    client4 = NightCamera.Client(protocol4)

    protocol5 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "securityCamera2")
    client5 = SecurityCamera.Client(protocol5)

    protocol6 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "nightCamera2")
    client6 = NightCamera.Client(protocol6)

    protocol7 = TMultiplexedProtocol.TMultiplexedProtocol(TBinaryProtocol.TBinaryProtocol(transport), "listDevices")
    client7 = ListDevices.Client(protocol7)

    # Create a client to use the protocol encoder
    menu()

    # Connect!
    transport.open()

    while True:
        selection = input("===>")

        if(selection == "getDevices"):
            print(client7.getDevices())
        elif(selection == "turnOn securityCamera"):
            client3.turnOn()
        elif(selection == "turnOn nightCamera"):
            client4.turnOn()
        elif(selection == "turnOn securityCamera2"):
            client5.turnOn()
        elif(selection == "turnOn nightCamera2"):
            client6.turnOn()
        elif(selection == "turnOn topFreezer"):
            client.turnOn()
        elif(selection == "turnOn compactFridge"):
            client2.turnOn()
        elif(selection == "turnOff securityCamera"):
            client3.turnOff()
        elif(selection == "turnOff nightCamera"):
            client4.turnOff()
        elif(selection == "turnOff topFreezer"):
            client.turnOff()
        elif(selection == "turnOff compactFridge"):
            client2.turnOff()
        elif(selection == "turnOff securityCamera2"):
            client5.turnOff()
        elif(selection == "turnOff nightCamera2"):
            client6.turnOff()
        elif(selection == "getPower securityCamera"):
            print(Power._VALUES_TO_NAMES.get(client3.getPower()))
        elif(selection == "getPower nightCamera"):
            print(Power._VALUES_TO_NAMES.get(client4.getPower()))
        elif(selection == "getPower topFreezer"):
            print(Power._VALUES_TO_NAMES.get(client.getPower()))
        elif(selection == "getPower compactFridge"):
            print(Power._VALUES_TO_NAMES.get(client2.getPower()))
        elif(selection == "getPower securityCamera2"):
            print(Power._VALUES_TO_NAMES.get(client5.getPower()))
        elif(selection == "getPower nightCamera2"):
            print(Power._VALUES_TO_NAMES.get(client6.getPower()))
        elif(selection == "open topFreezer"):
            client.open()
        elif(selection == "open compactFridge"):
            client2.open()
        elif(selection == "close topFreezer"):
            client.close()
        elif(selection == "close compactFridge"):
            client2.close()
        elif(selection == "getStatus topFreezer"):
            print(Status._VALUES_TO_NAMES.get(client.getStatus()))
        elif(selection == "getStatus compactFridge"):
            print(Status._VALUES_TO_NAMES.get(client2.getStatus()))
        elif("setTemperature topFreezer" in selection):
            try:
                client.setTemperature(float(selection[25:-1]))
            except BadTemperature as e:
                print('InvalidOperation: %r' % e)
        elif("setTemperature compactFridge" in selection):
            try:
                client2.setTemperature(float(selection[28:-1]))
            except BadTemperature as e:
                print('InvalidOperation: %r' % e)
        elif(selection == "getTemperature topFreezer"):
            print(client.getTemperature())
        elif(selection == "getTemperature compactFridge"):
            print(client2.getTemperature())
        elif(selection == "getColor compactFridge"):
            print(Color._VALUES_TO_NAMES.get(client2.getColor()))
        elif("setColor compactFridge" in selection):
            try:
                client2.setColor(Color._NAMES_TO_VALUES.get(selection[23:-1]))
            except BadColor as e:
                print('InvalidOperation: %r' % e)
        elif(selection == "openFreezer topFreezer"):
            client.openFreezer()
        elif(selection == "closeFreezer topFreezer"):
            client.closeFreezer()
        elif(selection == "getFreezerStatus topFreezer"):
            print(Status._VALUES_TO_NAMES.get(client.getFreezerStatus()))
        elif("setFreezerTemperature topFreezer" in selection):
            try:
                client.setFreezerTemperature(float(selection[32:-1]))
            except BadTemperature as e:
                print('InvalidOperation: %r' % e)
        elif(selection == "getFreezerTemperature topFreezer"):
            print(client.getFreezerTemperature())
        elif(selection == "getPicture securityCamera"):
            bits = client3.getPicture()
            f = open('client3.jpg', 'w+b')
            f.write(bits)
            f.close()
        elif(selection == "getPicture nightCamera"):
            bits = client4.getPicture()
            f = open('client4.jpg', 'w+b')
            f.write(bits)
            f.close()
        elif(selection == "getPicture securityCamera2"):
            bits = client5.getPicture()
            f = open('client5.jpg', 'w+b')
            f.write(bits)
            f.close()
        elif(selection == "getPicture nightCamera2"):
            bits = client6.getPicture()
            f = open('client6.jpg', 'w+b')
            f.write(bits)
            f.close()
        elif("rotate securityCamera2" in selection):
            try:
                print(client5.rotate(Rotate._NAMES_TO_VALUES.get(selection[23:-1])))
            except RotateException as e:
                print('InvalidOperation: %r' % e)
        elif("zoom securityCamera2" in selection):
            try:
                print(client5.zoom(Zoom._NAMES_TO_VALUES.get(selection[21:-1])))
            except ZoomException as e:
                print('InvalidOperation: %r' % e)
        elif("rotate securityCamera" in selection):
            try:
                print(client3.rotate(Rotate._NAMES_TO_VALUES.get(selection[22:-1])))
            except RotateException as e:
                print('InvalidOperation: %r' % e)
        elif("zoom securityCamera" in selection):
            try:
                print(client3.zoom(Zoom._NAMES_TO_VALUES.get(selection[20:-1])))
            except ZoomException as e:
                print('InvalidOperation: %r' % e)
        elif(selection == "turnOnNightvision nightCamera"):
            client4.turnOnNightvision()
        elif(selection == "turnOffNightvision nightCamera"):
            client4.turnOffNightvision()
        elif(selection == "getNightvisionStatus nightCamera"):
            print(NightvisionStatus._VALUES_TO_NAMES.get(client4.getNightvisionStatus()))
        elif(selection == "turnOnNightvision nightCamera2"):
            client6.turnOnNightvision()
        elif(selection == "turnOffNightvision nightCamera2"):
            client6.turnOffNightvision()
        elif(selection == "getNightvisionStatus nightCamera2"):
            print(NightvisionStatus._VALUES_TO_NAMES.get(client6.getNightvisionStatus()))
        else:
            print("Invalid choice")
            menu()

    
    transport.close()

def menu():
    print("""
    usage:
    getDevices
    turnOn securityCamera|nightCamera|topFreezer|compactFridge
    turnOff securityCamera|nightCamera|topFreezer|compactFridge
    getPower securityCamera|nightCamera|topFreezer|compactFridge
    open topFreezer|compactFridge
    close topFreezer|compactFridge
    getStatus topFreezer|compactFridge
    setTemperature topFreezer|compactFridge value
    getTemperature topFreezer|compactFridge
    getColor compactFridge
    setColor compactFridge BLUE|RED|GREEN
    openFreezer topFreezer
    closeFreezer topFreezer
    getFreezerStatus topFreezer
    setFreezerTemperature topFreezer value
    getFreezerTemperature topFreezer
    getPicture securityCamera|nightCamera
    rotate securityCamera LEFT|RIGHT|UP|DOWN
    zoom securityCamera IN|OUT
    turnOnNightvision nightCamera
    turnOffNightvision nightCamera
    getNightvisionStatus nightCamera
    """)


if __name__ == "__main__":
    # execute only if run as a script
    main()
