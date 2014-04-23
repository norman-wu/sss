#include "ast.h"
#include "tables.h"
#include "eval.h"
#include <assert.h>

int eval_debug = 0;

void debug_eval(int val)
{
    eval_debug = val;
}

value_t eval_exp(ast_t *e, varctx_t *tbl, memctx_t *mem)
{
  value_t ret;
  ret.value = DEFAULT_VAL;
  ret.taint = DEFAULT_TAINT;

  value_t e1;
  value_t e2;

    switch(e->tag){
    case int_ast: 
      ret.value = e->info.integer;
      ret.taint = false;
      return ret;
      break;
    case var_ast:
      return lookup_var(e->info.varname, tbl);
      break;
    case node_ast: {
	switch(e->info.node.tag){
	case MEM:
          e1 = eval_exp(e->info.node.arguments->elem, tbl,mem);
	  ret = load(e1.value, mem);
          ret.taint = ret.taint || e1.taint;
          return ret;
	  break;
	case PLUS:
          e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value + e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case MINUS:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value - e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case DIVIDE:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value / e2.value;
          ret.taint = (e1.value != 0 && e2.taint) ||
                      (e1.taint && e2.value != 0) ||
                      (e1.taint && e2.taint);
          return ret;
	  break;
	case TIMES:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value * e2.value;
          ret.taint = (e1.value != 0 && e2.taint) ||
                      (e1.taint && e2.value != 0) ||
                      (e1.taint && e2.taint);
          return ret;
	  break;

	case EQ:
          e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value == e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case NEQ:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value != e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case GT:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value > e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case LT:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value < e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case LEQ:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value <= e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case GEQ:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value >= e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case AND:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value && e2.value;
          ret.taint = (e1.value == true && e2.taint) ||
                      (e1.taint && e2.value == true) ||
                      (e1.taint && e2.taint);
          return ret;
	    break;
	case OR:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value && e2.value;
          ret.taint = (e1.value == true && e2.taint) ||
                      (e1.taint && e2.value == true) ||
                      (e1.taint && e2.taint);
          return ret;
	  break;
	case NEGATIVE:
          e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          ret.value = -e1.value;
          ret.taint = e1.taint;
          return ret;
          break;
	case NOT:
	  e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          ret.value = !e1.value;
          ret.taint = e1.taint;
          return ret;
          break;
	case READINT:
	  printf("> ");
	  scanf("%u", &(ret.value));
          ret.taint = false;
	  return ret;
	  break;
	case READSECRETINT:
	  printf("# ");
	  scanf("%u", &(ret.value));
          ret.taint = true;
	  return ret;
	  break;
	default:
	  assert(0); // Unknown/unhandled op.
	}
    }
    }
}

state_t* eval_stmts(ast_t *p, state_t *state)
{
    ast_list_t *stmts;
    ast_list_t *ip;
    ast_t *t1, *t2;
    ast_t *s;
    value_t v;

    assert(p != NULL);
    assert(p->info.node.tag == SEQ);
    ip = p->info.node.arguments;
    while(ip != NULL)
    {
	s = ip->elem;
        value_t e1;

	switch(s->info.node.tag){
	case ASSIGN:
	    /* the lhs */
	    t1 = s->info.node.arguments->elem;
	    /* the rhs */
	    t2 = s->info.node.arguments->next->elem;
	    v = eval_exp(t2, state->tbl, state->mem);
	    switch(t1->tag){
	    case var_ast:
		state->tbl = update_var(t1->info.string, v, state->tbl);
		break;
	    case node_ast:
		assert(t1->info.node.tag == MEM);
		state->mem = store(eval_exp(t1->info.node.arguments->elem,
					  state->tbl, 
					  state->mem).value, v, state->mem);
		break;
	    default:
		assert(0);
	    }
	  break;
	case PRINT:
	    switch(s->info.node.arguments->elem->tag){
	    case str_ast:
		printf("%s\n", s->info.node.arguments->elem->info.string);
		break;
	    default:
                e1 = eval_exp(s->info.node.arguments->elem, 
					state->tbl,
					state->mem);
                if (e1.taint) {
                  fprintf(stderr,"%s\n","Tainted variable: Some");
                  printf("%s\n", "<secret>");
                }
                else {
                  fprintf(stderr,"%s\n","Tainted variable: None");
                  printf("%u\n", e1.value);
                }
		break;
	    }

	  break;
	case IF:
        //control-flow taint shall NOT be tracked, so no changes here

	    if(eval_exp(s->info.node.arguments->elem, state->tbl, state->mem).value){
		state = eval_stmts(s->info.node.arguments->next->elem, state);
	    } else {
		state = eval_stmts(s->info.node.arguments->next->next->elem, state);
            } 
	  break;
	case SEQ:
	    state = eval_stmts(s->info.node.arguments->next->elem, state);
	  break;
	case ASSERT:
	    if(eval_exp(s->info.node.arguments->elem, state->tbl,state->mem).value ==0){
		printf("Assert failed!\n");
	    }
	  break;
	default:
	  printf("Unknown statement type\n");
	  assert(0);
	  break;
	}
	ip = ip->next;
    }
    return state;
}
