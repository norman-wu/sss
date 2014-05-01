#include <stdlib.h>
#include "tables.h"

extern int eval_debug;


varctx_t *newvar(char *name, varctx_t *o)
{
  varctx_t *n = (varctx_t *)malloc(sizeof(varctx_t));
  n->name = name;
  n->val.value = DEFAULT_VAL;
  n->val.taint = DEFAULT_TAINT;
  n->next = o;
  return n;
}

value_t lookup_var(char *name, varctx_t *c)
{
  value_t ret;
  ret.value = DEFAULT_VAL;
  ret.taint = DEFAULT_TAINT;
  
  while(c != NULL){
    if(strcmp(c->name, name) == 0){
      if(eval_debug)
	printf("[Debug] lookup: %s value: %x\n", name, c->val.value);
      return c->val;
    }
    c=c->next;
  }
  if(eval_debug)
    printf("[Debug] lookup: %s <uninitialized. returning %d>", name, DEFAULT_VAL);
  return ret;
}

varctx_t * update_var(char *name, value_t val, varctx_t *o)
{
  varctx_t *c = o;
  varctx_t *n = NULL;

  while(c != NULL){
    if(strcmp(c->name, name) == 0){
      if(eval_debug){
	printf("[Debug] update %s with %x (old value %x)\n", name, val.value, c->val.value);
      }
      c->val = val;
      return o;
    }
    c= c->next;
  }
  n = (varctx_t *)malloc(sizeof(varctx_t));
  n->name = name;
  n->val = val;
  n->next = o;
  if(eval_debug){
    printf("[Debug] update %s with %x (new node)\n", name, val.value);
  }

  return n;
}

memctx_t *store(unsigned int addr, value_t val, memctx_t *o)
{
  memctx_t *n = NULL;
  memctx_t *c = o;
  while(c != NULL){
    if(c->addr == addr){
      if(eval_debug){
	printf("[Debug] store %x with %x (replacing %x)\n", c->addr,
	       val.value, c->val.value);
      }

      c->val = val;
      return o;
    }
    c = c->next;
  }
  /* we didn't find the address. create a new spot in the context */
  n = (memctx_t *)(malloc(sizeof(memctx_t)));
  n->addr = addr;
  n->val = val;
  n->next = o;
  if(eval_debug){
    printf("[Debug] store %x with %x (new node)\n", n->addr, val.value);
  }

  return n;
}

value_t load(unsigned int addr, memctx_t *c)
{
  value_t ret;
  ret.value = DEFAULT_VAL;
  ret.taint = DEFAULT_TAINT;
  while(c != NULL){
    if(c->addr == addr){
      if(eval_debug)
	printf("[Debug] load: %x value: %x\n", addr, c->val.value);
      return c->val;
    }
    c = c->next;
  }
  printf("[Debug] load: %x <uninitialized. returning %x>\n", addr, DEFAULT_VAL);
  return ret;
}


void print_memctx(memctx_t *c)
{
  while(c != NULL){
    printf("[Debug] mem[%x] =  %x\n", c->addr, c->val.value);
    c = c->next;
  }
}
