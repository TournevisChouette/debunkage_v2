/* Décale l'horloge « temps réel » vue par un processus i386 (wine32) de OFF secondes vers le passé.
   Aucune dépendance (ni libc ni libgcc) : appels système directs. */
typedef long long s64;
struct kts { s64 s; s64 ns; };
struct ts64 { s64 tv_sec; long tv_nsec; long pad; };
struct tv64 { s64 tv_sec; s64 tv_usec; };
static long sc2(long n, long a, long b){ long r;
  __asm__ volatile ("pushl %%ebx; movl %%edx,%%ebx; int $0x80; popl %%ebx" : "=a"(r) : "0"(n), "d"(a), "c"(b) : "memory");
  return r; }
static long lire(int clk, struct kts *k){ return sc2(403, clk, (long)k); } /* clock_gettime64 */
int __clock_gettime64(int clk, struct ts64 *t){ struct kts k; long r=lire(clk,&k); if(r<0) return -1;
  if(clk==0||clk==5||clk==8) k.s-=OFF; t->tv_sec=k.s; t->tv_nsec=(long)k.ns; return 0; }
int __gettimeofday64(struct tv64 *tv, void *tz){ struct kts k; if(lire(0,&k)<0) return -1;
  if(tv){ tv->tv_sec=k.s-OFF; tv->tv_usec=(s64)((unsigned long)k.ns/1000UL); } return 0; }
s64 __time64(s64 *p){ struct kts k; lire(0,&k); k.s-=OFF; if(p)*p=k.s; return k.s; }
/* variantes 32 bits, par sûreté */
struct ts32 { long tv_sec; long tv_nsec; }; struct tv32 { long tv_sec; long tv_usec; };
int clock_gettime(int clk, struct ts32 *t){ struct kts k; long r=lire(clk,&k); if(r<0) return -1;
  if(clk==0||clk==5||clk==8) k.s-=OFF; t->tv_sec=(long)k.s; t->tv_nsec=(long)k.ns; return 0; }
int gettimeofday(struct tv32 *tv, void *tz){ struct kts k; if(lire(0,&k)<0) return -1;
  if(tv){ tv->tv_sec=(long)(k.s-OFF); tv->tv_usec=(long)((unsigned long)k.ns/1000UL);} return 0; }
long time(long *p){ struct kts k; lire(0,&k); long v=(long)(k.s-OFF); if(p)*p=v; return v; }
