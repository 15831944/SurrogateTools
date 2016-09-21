#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "list.h"

elem_t DATANULL;
static int qinitialized=0;

#ifdef STRUCT_STACK
int listnull(elem_t e) {return e.f1 = 0 && e.f2 == 0;}
#else
int listnull(elem_t e) {return e == (elem_t)0;}
#endif

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define DEFAULTALLOC 16
#define ALLOCINCR 16

List* listnew(void)
{
  List* sq;
  if(!qinitialized) {
    memset((void*)&DATANULL,0,sizeof(elem_t));
    qinitialized = 1;
  }
  sq = (List*)malloc(sizeof(List));
  if(sq) {
    sq->alloc=0;
    sq->length=0;
    sq->content=NULL;
  }
  return sq;
}

int
listfree(List* sq)
{
  if(sq) {
    sq->alloc = 0;
    if(sq->content != NULL) {free(sq->content); sq->content = NULL;}
    free(sq);
  }
  return TRUE;
}

int
listsetalloc(List* sq, unsigned int sz)
{
  elem_t* newcontent;
  if(sq == NULL) return FALSE;
  if(sz <= 0) {sz = (sq->length?2*sq->length:DEFAULTALLOC);}
  else if(sq->alloc >= sz) {return TRUE;}
  newcontent=(elem_t*)calloc(sz,sizeof(elem_t));
  if(sq->alloc > 0 && sq->length > 0 && sq->content != NULL) {
    memcpy((void*)newcontent,(void*)sq->content,sizeof(elem_t)*sq->length);
    free(sq->content);
  }
  sq->content=newcontent;
  sq->alloc=sz;
  return TRUE;
}

#ifndef LINLINE
int
listsetlength(List* sq, unsigned int sz)
{
  if(sq == NULL) return FALSE;
  if(!listsetalloc(sq,sz)) return FALSE;
  sq->length = sz;
  return TRUE;
}

elem_t
listget(List* sq, unsigned int index)
{
  if(sq == NULL || sq->length == 0) return DATANULL;
  if(index >= sq->length) return DATANULL;
  return sq->content[index];
}
#endif

int
listset(List* sq, unsigned int index, elem_t elem)
{
  if(sq == NULL) return FALSE;
  if(index >= sq->length) return FALSE;
  sq->content[index] = elem;
  return TRUE;
}

/* Insert at position i of sq; will push up elements i..|seq|. */
int
listinsert(List* sq, unsigned int index, elem_t elem)
{
  unsigned int i;
  if(sq == NULL) return FALSE;
  if(index > sq->length) return FALSE;
  listsetalloc(sq,0);
  for(i=sq->length;i>index;i--) sq->content[i] = sq->content[i-1];
  sq->content[index] = elem;
  sq->length++;
  return TRUE;
}

#ifndef LINLINE
int
listpush(List* sq, elem_t elem)
{
  if(sq == NULL) return FALSE;
  if(sq->length >= sq->alloc) listsetalloc(sq,0);
  sq->content[sq->length] = elem;
  sq->length++;
  return TRUE;
}
#endif

int
listfpush(List* sq, elem_t elem)
{
  unsigned int i;
  if(sq == NULL) return FALSE;
  if(sq->length >= sq->alloc) listsetalloc(sq,0);
  /* could we trust bcopy? instead */
  for(i=sq->alloc;i>=1;i--) {sq->content[i]=sq->content[i-1];}
  sq->content[0] = elem;
  sq->length++;
  return TRUE;
}

elem_t
listpop(List* sq)
{
  if(sq == NULL || sq->length == 0) return DATANULL;
  sq->length--;  
  return sq->content[sq->length];
}

elem_t
listtop(List* sq)
{
  if(sq == NULL || sq->length == 0) return DATANULL;
  return sq->content[sq->length - 1];
}

elem_t
listfpop(List* sq)
{
  elem_t elem;
  if(sq == NULL || sq->length == 0) return DATANULL;
  elem = sq->content[0];
  memcpy((void*)&sq->content[0],(void*)&sq->content[1],
           sizeof(elem_t)*(sq->length - 1));
  sq->length--;  
  return elem;
}

elem_t
listfront(List* sq)
{
  if(sq == NULL || sq->length == 0) return DATANULL;
  return sq->content[0];
}

elem_t
listremove(List* sq, unsigned int i)
{
  unsigned int len;
  elem_t elem;
  if(sq == NULL || (len=sq->length) == 0) return DATANULL;
  if(i >= len) return DATANULL;
  elem = sq->content[i];
  for(i++;i<len;i++) sq->content[i-1] = sq->content[i];
  sq->length--;
  return elem;  
}

/* Duplicate and return the content (null terminate) */
elem_t*
listdup(List* sq)
{
    elem_t* result = (elem_t*)malloc(sq->length+1);
    memcpy((void*)result,(void*)sq->content,sizeof(elem_t)*sq->length);
    result[sq->length] = (elem_t)0;
    return result;
}

