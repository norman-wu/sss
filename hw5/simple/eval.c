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
  ret.tainted = DEFAULT_TAINT;

    switch(e->tag){
    case int_ast: return e->info.integer; break;
    case var_ast: return lookup_var(e->info.varname, tbl); break;
    case node_ast: {
	switch(e->info.node.tag){
	case MEM:
          value_t e1 = eval_exp(e->info.node.arguments->elem, tbl,mem);
	  ret = load(e1.value, mem);
          ret.taint = ret.taint || e1.taint;
          return ret;
	  break;
	case PLUS:
          value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value + e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case MINUS:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value - e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case DIVIDE:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value / e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case TIMES:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value * e2.value;
          ret.taint = (e1.value != 0 && e2.taint) ||
                      (e1.taint && e2.value != 0) ||
                      (e1.taint && e2.taint);
          return ret;
	  break;

	case EQ:
          value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value == e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case NEQ:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value != e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	  break;
	case GT:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value > e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case LT:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value < e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case LEQ:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value <= e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case GEQ:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value >= e2.value;
          ret.taint = e1.taint || e2.taint;
          return ret;
	    break;
	case AND:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value && e2.value;
          ret.taint = (e1.value == true && e2.taint) ||
                      (e1.taint && e2.value == true) ||
                      (e1.taint && e2.taint);
          return ret;
	    break;
	case OR:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          value_t e2 = eval_exp(e->info.node.arguments->next->elem,tbl,mem);
          ret.value = e1.value && e2.value;
          ret.taint = (e1.value == true && e2.taint) ||
                      (e1.taint && e2.value == true) ||
                      (e1.taint && e2.taint);
          return ret;
	  break;
	case NEGATIVE:
          value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
          ret.value = -e1.value;
          ret.taint = e1.taint;
          return ret;
          break;
	case NOT:
	  value_t e1 = eval_exp(e->info.node.arguments->elem,tbl,mem);
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
					  state->mem), v, state->mem);
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
		printf("%u\n", eval_exp(s->info.node.arguments->elem, 
					state->tbl,
					state->mem));
		break;
	    }

	  break;
	case IF:
        //control-flow taint shall NOT be tracked, so no changes here

	    if(eval_exp(s->info.node.arguments->elem, state->tbl, state->mem)){
		state = eval_stmts(s->info.node.arguments->next->elem, state);
	    } else {
		state = eval_stmts(s->info.node.arguments->next->next->elem, state);
            } 
	  break;
	case SEQ:
	    state = eval_stmts(s->info.node.arguments->next->elem, state);
	  break;
	case ASSERT:
	    if(eval_exp(s->info.node.arguments->elem, state->tbl,state->mem) ==0){
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
