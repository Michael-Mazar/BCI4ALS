import matlab.engine

eng = matlab.engine.start_matlab()

tf = eng.isprime(6)
print(tf)