import numpy as np
import matplotlib.pyplot as plt

x = [2,3,4]
y = [40,90,196]

f1 = np.polyfit(x, y, 1)
p1 = np.poly1d(f1)

f3 = np.polyfit(x, y, 3)
p3 = np.poly1d(f3)
pe = np.poly1d(np.polyfit(x, np.log(y), 1))

l = np.arange(1,128,0.1)

# print(p3)
print(np.exp(pe(64)))

plt.loglog(l, [p1(k) for k in l], label="%s" %p1)
plt.loglog(l, [p3(k) for k in l], label="%s" %p3)
plt.loglog(l, np.exp([pe(k) for k in l]), label="exp(%s)" %pe)
plt.grid(which="both")
plt.legend()
plt.show()