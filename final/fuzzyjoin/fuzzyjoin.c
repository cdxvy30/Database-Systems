#include "postgres.h"

/* OS Includes */
/* PostgreSQL Includes */
PG_MODULE_MAGIC;
void _PG_init(void);
void _PG_fini(void);
Datum pg_all_queries(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pg_all_queries);
static void process_utility(PlannedStmt *pstmt, const char *queryString,ProcessUtilityContext context,ParamListInfo params,QueryEnvironment *queryEnv,DestReceiver *dest,       char *completionTag);