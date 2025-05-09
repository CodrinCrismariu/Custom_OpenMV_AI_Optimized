/*
 * SPDX-License-Identifier: MIT
 *
 * Copyright (C) 2013-2024 OpenMV, LLC.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Common data structures.
 */
#ifndef __COLLECTIONS_H__
#define __COLLECTIONS_H__
#include <stdbool.h>
#include <stddef.h>

// Bitmap
typedef struct bitmap {
    size_t size;
    char *data;
} bitmap_t;

void bitmap_alloc(bitmap_t *ptr, size_t size);
void bitmap_free(bitmap_t *ptr);
void bitmap_clear(bitmap_t *ptr);
void bitmap_bit_set(bitmap_t *ptr, size_t index);
bool bitmap_bit_get(bitmap_t *ptr, size_t index);
#define BITMAP_COMPUTE_ROW_INDEX(image, y)    (((image)->w) * (y))
#define BITMAP_COMPUTE_INDEX(row_index, x)    ((row_index) + (x))

// LIFO
typedef struct lifo {
    size_t len;
    size_t size;
    size_t data_len;
    char *data;
} lifo_t;

void lifo_alloc(lifo_t *ptr, size_t size, size_t data_len);
void lifo_alloc_all(lifo_t *ptr, size_t *size, size_t data_len);
void lifo_free(lifo_t *ptr);
void lifo_clear(lifo_t *ptr);
size_t lifo_size(lifo_t *ptr);
bool lifo_is_not_empty(lifo_t *ptr);
bool lifo_is_not_full(lifo_t *ptr);
void lifo_enqueue(lifo_t *ptr, void *data);
void lifo_dequeue(lifo_t *ptr, void *data);
void lifo_poke(lifo_t *ptr, void *data);
void lifo_peek(lifo_t *ptr, void *data);

// FIFO
typedef struct fifo {
    size_t head;
    size_t tail;
    size_t len;
    size_t size;
    size_t data_len;
    char *data;
} fifo_t;

void fifo_alloc(fifo_t *ptr, size_t size, size_t data_len);
void fifo_alloc_all(fifo_t *ptr, size_t *size, size_t data_len);
void fifo_free(fifo_t *ptr);
void fifo_clear(fifo_t *ptr);
size_t fifo_size(fifo_t *ptr);
bool fifo_is_not_empty(fifo_t *ptr);
bool fifo_is_not_full(fifo_t *ptr);
void fifo_enqueue(fifo_t *ptr, void *data);
void fifo_dequeue(fifo_t *ptr, void *data);
void fifo_poke(fifo_t *ptr, void *data);
void fifo_peek(fifo_t *ptr, void *data);

// Linked List
typedef struct list_lnk {
    struct list_lnk *next;
    struct list_lnk *prev;
    char data[];
} list_lnk_t;

typedef struct list {
    list_lnk_t *head;
    list_lnk_t *tail;
    size_t size;
    size_t data_len;
} list_t;

void list_init(list_t *ptr, size_t data_len);
void list_copy(list_t *dst, list_t *src);
void list_free(list_t *ptr);
void list_clear(list_t *ptr);
size_t list_size(list_t *ptr);
void list_insert(list_t *ptr, list_lnk_t *lnk, void *data);
void list_push_front(list_t *ptr, void *data);
void list_push_back(list_t *ptr, void *data);
void list_remove(list_t *ptr, list_lnk_t *lnk, void *data);
void list_pop_front(list_t *ptr, void *data);
void list_pop_back(list_t *ptr, void *data);
void list_move(list_t *dst, list_t *src, list_lnk_t *before, list_lnk_t *lnk);
void list_move_front(list_t *dst, list_t *src, list_lnk_t *lnk);
void list_move_back(list_t *dst, list_t *src, list_lnk_t *lnk);
#define list_for_each(iterator, list) \
    for (list_lnk_t *iterator = list->head; iterator != NULL; iterator = iterator->next)
#define list_get_data(iterator) ((void *) iterator->data)
#endif /* __COLLECTIONS_H__ */
