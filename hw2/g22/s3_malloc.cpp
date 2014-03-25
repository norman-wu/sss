// s3_malloc.c
// stateful "malloc return" value checker

#include "extend-lang.hpp"     // Extend API


// ------------------------ the checker ----------------------
// This store maps expressions to AbsValue; unmapped expressions
// have unknown sign.
START_EXTEND_CHECKER( s3_malloc, int_store );


ANALYZE_TREE()
{
  // general information about the current tree
  {
    CallSite malloc("malloc");
    Var lv;
    AnySubpart lv_sp(lv);
    AnyExpression cond;
    Pointer p;

    if(MATCH( lv_sp= malloc(_))) {
      SET_STATE(lv_sp, 1);
      ADD_EVENT(lv_sp, "malloc", "malloc assigned to" << lv_sp);
      cout << lv_sp << " malloc at " <<  current_file_lineno() << endl;
      return;
    }  
    else if (MATCH(IfPat(cond))) {
      int i;
      if (GET_STATE(cond, i)) {
        if (MATCH_STATE(cond, 1)) {
	       SET_STATE(cond, 0);
	       ADD_EVENT(cond, "check", "malloc checked" << cond);
	       }
      } 
      return;
    }
    else if (MATCH(Contains(p))) {
      int i;
    	if (GET_STATE(p, i)) {
        if (MATCH_STATE(p, 1)) {
          SET_STATE(p, 2);     
          COMMIT_ERROR( p, "malloc", "malloc was not checked for return value at " << current_file_lineno() );
	       }
      } 
      return;
    }
  }                                                      
}

END_EXTEND_CHECKER();

MAKE_MAIN( s3_malloc )

// EOF
