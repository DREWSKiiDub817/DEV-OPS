# **Networking**

## *Switching*
ip link  - list  
ip addr   
ip addr add 192.168.1.10/24 dev eth0  
ip route  
ip route add 192.168.1.0/24 via 192.168.2.1

## *Routing*
 cat /proc/sys/net/ipv4/ip_forward  
 : set value to 1, will revert after restart
 ## *DNS*

cat /etc/resolv.conf  
* nameserver      192.168.1.100  
* nameserver        8.8.8.8

cat >> /etc/hosts  
* 192.168.1.115  test  

cat /etc/nsswitch.conf
* ... hosts:   files dns ...

## *Namespaces*
On the container:
* ps aux
On the host:
* ps aux

## *Network Namespace*
Create Network NS
* ip netns add red
* ip netns add blue
* ip netns  

List interfaces on host
* ip link

List interfaces on container
* ip netns exex red ip link
* ip -n red link

Create a link between network namespaces
* ip link add veth-red type veth peer name veth-blue
* ip link set veth-red netns red
* ip link set veth-blue netns blue

Assign IP add to each network namespace
* ip -n red addr add 192.168.15.1 dev veth-red
* ip -n blue addr add 192.168.15.1 dev veth-blue

Bring interfaces up
* ip -n red link set veth-red up
* ip -n blue link set veth-blue up

ip netns exec red ping 192.168.15.2

## *Create a internal vertual switch*
**Linux Bridge**
* ip link add v-net-0 type bridge
* ip link
* ip link set dev v-net-0 up

## *Connect Network Namespaces to Bridge*
* ip link add veth-red type veth peer name veth-red-br
  * ip link set veth-red netns red
  * ip link set veth-red-br master v-net-0
  * ip -n red addr add 192.168.15.1 dev veth-red
  * ip -n red link set veth-red up
* ip link add veth-blue type veth peer name veth-blue-br
  * ip link set veth-blue netns blue
  * ip link set veth-blue-br master v-net-0
  * ip -n blue addr add 192.168.15.1 dev veth-blue
  * ip -n blue link set veth-blue up
  
## *Important Ports*
**Master node(s):**
* Kube-apiserver: **6443**
* Kubelet: **10250**
* Kube-scheduler: **10259**
* Kube-controller-manager: **10257**
* ETCD: **2379 - 2380**

**Worker node(s):**
* Kube-apiserver: **6443**
* Services: **30000 - 32767**

## *Lab*
* ip link  
* kubectl get nodes -o wide  
* ip a | grep -B2 192.26.59.9  
* ssh node01  
* ip link show eth0  

## *Pod Networking*
**Networking Model**
* Every POD should have an IP Address
* Every POD should be able to communicate with every other POD in the same node.
* Every POD should be able to communicate with every other POD on other nodes without NAT.

<br>

## *Topology*
*Reference POD_Networking.png image*
* **NODE1:** 192.168.1.11
  * **V-Net-0:** 10.244.1.1
      * **POD_1:** 10.244.1.2
  
<br>

* **NODE2:** 192.168.1.12
  * **V-Net-0:** 10.244.2.1
      * **POD_2:** 10.244.2.2

<br>

## *To ping from POD_1 to POD_2*
## Option 1
* Create a route on NODE_1:
  * ip route add 10.244.2.2 via 192.168.1.12
* Create a route on NODE_2:
  * ip route add 10.244.1.2 via 192.168.1.11
## Option 2
* Create a routing table on the Router:
  * 10.244.1.0/24 : 192.168.1.11
  * 10.244.2.0/24 : 192.168.1.12
  * 10.244.3.0/24 : 192.168.1.13

## *Lab*
* ps aux | grep kubelet | grep network
* ls /opt/cni/bin
* ls /etc/cni/net.d/
* cat /etc/cni/net.d/\<file>.conflist


