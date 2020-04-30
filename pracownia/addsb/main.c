#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/time.h>

#define __noinline __attribute__((noinline))

extern uint64_t addsb(uint64_t x, uint64_t y);

/* https://en.wikipedia.org/wiki/Xorshift#xorshift* */
static uint64_t random_u64(uint64_t *seed) {
  uint64_t x = *seed;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *seed = x;
  return x * 0x2545F4914F6CDD1DUL;
}

/* Only for testing. Such solution would get 0 points. */
static __noinline uint64_t addsb_iter(uint64_t x, uint64_t y) {
  uint64_t r = 0;
  for (int i = 0; i < 64; i += 8) {
    int xb = (int8_t)(x >> i);
    int yb = (int8_t)(y >> i);
    int rb = xb + yb;
    if (rb > INT8_MAX)
      rb = INT8_MAX;
    if (rb < INT8_MIN)
      rb = INT8_MIN;
    r |= (uint64_t)(rb & 255) << i;
  }
  return r;
}

static void run(uint64_t x, uint64_t y) {
  uint64_t fast = addsb(x, y);
  uint64_t slow = addsb_iter(x, y);
  if (fast != slow) {
    printf("0x%016" PRIX64 " + 0x%016" PRIX64 " == 0x%016" PRIX64
           " (your answer: 0x%016" PRIX64 ")\n",
           x, y, slow, fast);
    exit(EXIT_FAILURE);
  }
}

int main(int argc, char *argv[]) {
  if (argc != 3)
    goto fail;

  if (strcmp("-r", argv[1])) {
    uint64_t x = strtoul(argv[1], NULL, 16);
    if (errno)
      goto fail;
    uint64_t y = strtoul(argv[2], NULL, 16);
    if (errno)
      goto fail;
    run(x, y);
    return EXIT_SUCCESS;
  } else {
    int times = strtol(argv[2], NULL, 10);
    if (times < 0)
      goto fail;

    struct timeval tv;
    gettimeofday(&tv, NULL);

    uint64_t seed = tv.tv_sec + tv.tv_usec * 1e6;

    for (int i = 0; i < times; i++)
      run(random_u64(&seed), random_u64(&seed));

    return EXIT_SUCCESS;
  }

fail:
  fprintf(stderr, "Usage: %s [-r TIMES] [NUMBER]\n", argv[0]);
  return EXIT_FAILURE;
}
