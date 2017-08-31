#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/ip.h>
#include <linux/in6.h>
#include <linux/if_tunnel.h>
#include <string.h>
#include <strings.h>
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>

#define PORT 65001
#define MAXPKLEN 1500


int
main (int argc, char *argv[])
{
	struct sockaddr_in my_addr, peer_addr;
	char pk[MAXPKLEN];
	int pklen;
	socklen_t peer_addr_len;
	int sockfd;
	struct ifreq ifr;
	struct ip_tunnel_parm p;
	struct in_addr ia;

	/* UDP socket */
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bzero(&my_addr, sizeof(my_addr));
        my_addr.sin_family = AF_INET;
        my_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	if (argc == 4) {
		/* Client */
		/* Usage: sit-ctl ifname local_addr remote_addr */
		/* Bind to a random port */
		bind(sockfd, (struct sockaddr *)&my_addr, sizeof(my_addr));
		/* Set peer address and port */
		bzero(&peer_addr, sizeof(peer_addr));
		inet_aton(argv[3], &peer_addr.sin_addr);
		peer_addr.sin_port = htons(PORT);
		peer_addr_len = sizeof(peer_addr);
		/* To be done: Prepare signed message */
		/* For now, just send local IP in plaintext */
		inet_aton(argv[2], &ia);
		pklen = sizeof(ia);
		memcpy(pk, &ia, pklen);
		/* Send packet */
		sendto(sockfd, pk, pklen, 0, (struct sockaddr *)&peer_addr, peer_addr_len);
	} else if (argc == 2) {
		/* Server */
		/* Bind to the defined port */
		my_addr.sin_port = htons(PORT);
		bind(sockfd, (struct sockaddr *)&my_addr, sizeof(my_addr));
		/* Peer address and port are not known yet (zeroized) */
		bzero(&peer_addr, sizeof(peer_addr));
		/* Receive messages */
		while (1) {
			peer_addr_len = sizeof(peer_addr);
			pklen = recvfrom(sockfd, pk, MAXPKLEN, 0, (struct sockaddr *)&peer_addr, &peer_addr_len);
			fprintf(stderr, "RX %d\n", pklen);
			/* Verify packet contents and signature (to be done) */
			if (pklen == sizeof(ia)) {
				memcpy(&ia, pk, pklen);
				if (ia.s_addr == peer_addr.sin_addr.s_addr) {
					fprintf(stderr, "OK %s\n", inet_ntoa(ia));
					/* Modify tunnel destination */
					bzero(&ifr, sizeof(ifr));
					strncpy(ifr.ifr_name, argv[1], IFNAMSIZ);
					ifr.ifr_ifru.ifru_data = (void *)&p;
					ioctl(sockfd, SIOCGETTUNNEL, (void *)&ifr);
					perror(NULL);
					p.iph.daddr = ia.s_addr;
					ioctl(sockfd, SIOCCHGTUNNEL, (void *)&ifr);
					perror(NULL);
				}
			}
		}
	}
}
