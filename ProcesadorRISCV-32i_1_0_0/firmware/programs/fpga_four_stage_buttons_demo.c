static volatile unsigned int * const LED_MMIO = (volatile unsigned int *)0x00001000u;
static volatile unsigned int * const BTN_MMIO = (volatile unsigned int *)0x00001004u;

#define BTN_COUNT_MASK 0x2u
#define BTN_NEXT_MASK  0x4u
#define BTN_PREV_MASK  0x8u
#define ALL_BTN_MASK   0xFu
#define LED_MASK       0xFu

#define WAIT_BUTTON_SETTLE   60000u
#define WAIT_ANIMATION_LOOPS 250000u

enum demo_stage {
    STAGE_FIB = 0,
    STAGE_ALL_ON = 1,
    STAGE_COUNTER = 2,
    STAGE_ANIMATION = 3
};

static unsigned int read_buttons(void)
{
    return *BTN_MMIO & ALL_BTN_MASK;
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

static enum demo_stage next_stage(enum demo_stage stage)
{
    if (stage == STAGE_ANIMATION) {
        return STAGE_FIB;
    }

    return (enum demo_stage)(stage + 1);
}

static enum demo_stage prev_stage(enum demo_stage stage)
{
    if (stage == STAGE_FIB) {
        return STAGE_ANIMATION;
    }

    return (enum demo_stage)(stage - 1);
}

static void reset_stage_state(
    enum demo_stage stage,
    unsigned int *counter,
    unsigned int *pattern,
    unsigned int *moving_left
)
{
    if (stage == STAGE_COUNTER) {
        *counter = 0u;
    } else if (stage == STAGE_ANIMATION) {
        *pattern = 0x1u;
        *moving_left = 1u;
    }
}

int main(void)
{
    enum demo_stage stage = STAGE_FIB;
    unsigned int counter = 0u;
    unsigned int pattern = 0x1u;
    unsigned int moving_left = 1u;
    unsigned int fib_result = fib(2u);

    wait_button_release(ALL_BTN_MASK);

    for (;;) {
        switch (stage) {
        case STAGE_FIB:
            write_leds(fib_result);

            if (consume_button_press(BTN_NEXT_MASK) != 0u) {
                stage = next_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (consume_button_press(BTN_PREV_MASK) != 0u) {
                stage = prev_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            }
            break;

        case STAGE_ALL_ON:
            write_leds(0xFu);

            if (consume_button_press(BTN_NEXT_MASK) != 0u) {
                stage = next_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (consume_button_press(BTN_PREV_MASK) != 0u) {
                stage = prev_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            }
            break;

        case STAGE_COUNTER:
            write_leds(counter);

            if (consume_button_press(BTN_NEXT_MASK) != 0u) {
                stage = next_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (consume_button_press(BTN_PREV_MASK) != 0u) {
                stage = prev_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (consume_button_press(BTN_COUNT_MASK) != 0u) {
                counter = (counter + 1u) & LED_MASK;
            }
            break;

        case STAGE_ANIMATION:
            write_leds(pattern);
            wait_delay(WAIT_ANIMATION_LOOPS);

            if (consume_button_press(BTN_NEXT_MASK) != 0u) {
                stage = next_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (consume_button_press(BTN_PREV_MASK) != 0u) {
                stage = prev_stage(stage);
                reset_stage_state(stage, &counter, &pattern, &moving_left);
            } else if (moving_left != 0u) {
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
            break;

        default:
            stage = STAGE_FIB;
            break;
        }
    }
}
