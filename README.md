# Loop Tracker

Track which fixes are included in which release train/snap.

## Files

- **trains.csv** - Release train schedule with dates
- **fixes.csv** - All fixes and their target/actual trains
- **tracker.html** - Interactive web view (open in browser)

## How to Use

1. **Add a new fix**: Edit `fixes.csv`, add a row with bug details
2. **Update fix status**: Change the `Status` and `ActualTrain` columns
3. **View tracker**: Open `tracker.html` in a browser for filtering/searching

## Status Values

- `Pending` - Fix not yet in any train
- `Targeted` - Fix targeted for a specific train
- `Included` - Fix confirmed in the snap
- `Missed` - Fix missed the target train
- `Rolled Back` - Fix was rolled back
