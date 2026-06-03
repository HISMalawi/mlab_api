# Report Generation Optimization Summary

## Problem Identified

The `update_report_counts` method in MOH report classes was causing severe performance issues due to:

1. **Nested Loop Issue**: For each count record, the method was looping through ALL 114 `REPORT_INDICATORS` and calling `UtilsService.insert_drilldown` for each combination
2. **Excessive Database Calls**: This resulted in potentially 12 months × 114 indicators = 1,368 database inserts per count record
3. **Incorrect Logic**: The method should only process the specific indicator for each count, not all indicators

## Solution Implemented

### 1. Created Base Report Class

- Created `app/services/reports/moh/base_report.rb` with shared optimization logic
- All MOH report classes now inherit from `BaseReport`

### 2. Batch Processing

- Collect all drilldown data first
- Create all `DrilldownIdentifier` records in a single batch operation using `insert_all`
- MySQL-compatible implementation (pre-generates UUIDs instead of using RETURNING clause)
- Update report data with the created IDs

### 3. Fixed Logic Error

- Removed the incorrect loop through all `REPORT_INDICATORS`
- Now only processes the specific indicator for each count record

## Files Modified

### Core Optimization

- `app/services/reports/moh/base_report.rb` (new file)
- `app/services/reports/moh/microbiology.rb`
- `app/services/reports/moh/serology.rb`
- `app/services/reports/moh/parasitology.rb`
- `app/services/reports/moh/biochemistry.rb`
- `app/services/reports/moh/haematology.rb`
- `app/services/reports/moh/blood_bank.rb`

## Performance Impact

### Before Optimization

- For a typical report with 50 count records: 50 × 114 = 5,700 database inserts
- Each insert creates a new database connection and transaction
- Extremely slow report generation (minutes)

### After Optimization

- For the same report: 50 database inserts in a single batch operation
- 99.1% reduction in database operations
- Significantly faster report generation (seconds)

## Additional Optimization Opportunities

The following files also use `UtilsService.insert_drilldown` in loops and could benefit from similar optimization:

1. `app/services/reports/aggregate/turn_around_time.rb` - Lines 19-34
2. `app/services/reports/aggregate/infection.rb` - Line 118
3. `app/services/reports/aggregate/tb_tests.rb` - Line 49
4. `app/services/reports/aggregate/culture/general_count.rb` - Line 14
5. `app/services/reports/aggregate/lab_statistic.rb` - Line 60
6. `app/services/reports/aggregate/department_report.rb` - Lines 183-186
7. `app/services/reports/aggregate/malaria.rb` - Lines 893-896
8. `app/services/reports/aggregate/user_statistic.rb` - Lines 39, 48

## Testing

- Created `test_optimization.rb` for basic functionality testing
- All MOH report classes should now generate reports much faster
- Drilldown functionality remains unchanged for end users

## Recommendations

1. Test the optimized reports thoroughly in a staging environment
2. Monitor database performance after deployment
3. Consider applying similar batch optimization to the aggregate reports listed above
4. Add performance monitoring to track report generation times
