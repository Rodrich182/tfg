static volatile unsigned int * const LED_MMIO = (volatile unsigned int *)0x00001000u;
static volatile unsigned int * const BTN_MMIO = (volatile unsigned int *)0x00001004u;

#define BTN_RESUME_MASK 0x1u
#define BTN_COUNT_MASK  0x2u
#define LED_MASK        0xFu

#define WAIT_SHORT_LOOPS     30000u
#define WAIT_BUTTON_SETTLE   60000u
#define WAIT_ANIMATION_LOOPS 250000u

static unsigned int read_buttons(void)
{
    return *BTN_MMIO & LED_MASK;
}

static void write_leds(unsigned int value)
{
    *LED_MMIO = value & LED_MASK;
}

static void wait_delay(volatile unsigned int loops)
{
    volatile unsigned int i;

    for (i = 0u; i < loops; ++i) {
        __asm__ volatile ("" ::: "memory");
    }
}

static void breakpoint_halt(void)
{
    __asm__ volatile ("ecall" ::: "memory");
}

static void wait_button_release(unsigned int mask)
{
    while ((read_buttons() & mask) != 0u) {
    }

    wait_delay(WAIT_BUTTON_SETTLE);
}

static unsigned int consume_button_press(unsigned int mask)
{
    unsigned int buttons;

    buttons = read_buttons();
    if ((buttons & mask) == 0u) {
        return 0u;
    }

    wait_delay(WAIT_BUTTON_SETTLE);
    buttons = read_buttons();
    if ((buttons & mask) == 0u) {
        return 0u;
    }

    wait_button_release(mask);
    return 1u;
}

static unsigned int fib(unsigned int n)
{
    unsigned int a = 0u;
    unsigned int b = 1u;
    unsigned int i;

    if (n == 0u) {
        return 0u;
    }

    for (i = 0u; i < n; ++i) {
        unsigned int next = a + b;
        a = b;
        b = next;
    }

    return a;
}

static void run_counter_stage(void)
{
    unsigned int counter = 0u;

    write_leds(counter);
    wait_button_release(BTN_RESUME_MASK | BTN_COUNT_MASK);

    for (;;) {
        if (consume_button_press(BTN_RESUME_MASK) != 0u) {
            break;
        }

        if (consume_button_press(BTN_COUNT_MASK) != 0u) {
            counter = (counter + 1u) & LED_MASK;
            write_leds(counter);
            wait_delay(WAIT_SHORT_LOOPS);
        }
    }
}

static void run_animation_stage(void)
{
    unsigned int pattern = 0x1u;
    unsigned int moving_left = 1u;

    wait_button_release(BTN_RESUME_MASK | BTN_COUNT_MASK);

    for (;;) {
        write_leds(pattern);
        wait_delay(WAIT_ANIMATION_LOOPS);

        if (consume_button_press(BTN_RESUME_MASK) != 0u) {
            break;
        }

        if (moving_left != 0u) {
            pattern <<= 1u;
            if (pattern >= 0x8u) {
                pattern = 0x8u;
                moving_left = 0u;
            }
        } else {
            pattern >>= 1u;
            if (pattern <= 0x1u) {
                pattern = 0x1u;
                moving_left = 1u;
            }
        }
    }
}

int main(void)
{
    unsigned int fib_result;

    wait_button_release(BTN_RESUME_MASK | BTN_COUNT_MASK);

    fib_result = fib(2u);
    write_leds(fib_result);
    breakpoint_halt();

    write_leds(0xFu);
    breakpoint_halt();

    run_counter_stage();
    breakpoint_halt();

    run_animation_stage();
    breakpoint_halt();

    for (;;) {
        write_leds(0x0u);
    }
}
/**
 * while (true)
 * {
 *    writeled(read_button());
 * }
 * while (true){
 *  int dato = rea_buttons();
 * write_leds(dato);
 * 
 *  switch dato
 *      case "0001":
 * }
 * 
 */