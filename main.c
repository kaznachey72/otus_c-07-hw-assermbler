#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

const char *empty_str = "";
const char *int_format = "%ld ";
const int64_t data[] = { 4, 8, 15, 16, 23, 42 };
const size_t data_length = sizeof(data) / sizeof(data[0]);


typedef void(*UnaryFunc)(void*);
typedef bool(*UnaryPred)(int64_t);

// forward_list
typedef struct el {
    int64_t data;
    struct el *next;
} list_t;


void print_int(void *p)
{
    int64_t val = *(int64_t*)p;
    printf(int_format, val);
    fflush(NULL);
}

// fix memory leaks
void del_element(void *p)
{
    free(p);
}

// is_odd
bool p(int64_t val)
{
    return val & 1;
}

list_t *add_element(int64_t val, list_t *top)
{
    list_t *new_top = (list_t*) malloc(sizeof(list_t));
    if (!new_top) {
        abort();
    }

    new_top->data = val;
    new_top->next = top;
    return new_top;
}

// for_each
void m(list_t *top, UnaryFunc func)
{
    if (top) {
        list_t *next = top->next;

        func(top);
        m(next, func);
    }
}

// transform
list_t *f(list_t *i_top, list_t *o_top, UnaryPred pred)
{
    if (!i_top) {
        return o_top;
    }

    if (pred(i_top->data)) {
        o_top = add_element(i_top->data, o_top);
    }
    return f(i_top->next, o_top, pred);
}

int main()
{
    list_t *src = NULL;

    size_t i = data_length;
    while (i) {
        --i;
        int64_t val = data[i];
        src = add_element(val, src);
    }

    m(src, print_int);
    puts(empty_str);


    list_t *dst = NULL;
    dst = f(src, dst, p);

    m(dst, print_int);
    puts(empty_str);


    // fix memory leaks
    m(src, del_element);
    m(dst, del_element);

    return 0;
}
