echo Step 1: Cleaning the project
call flutter clean

echo Step 2: Getting dependencies
call flutter pub get

echo Step 3: Deploying the web app
call flutter run -d chrome --dart-define=SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsZ2Zna2xjeXBxdGJxcmtoc2JhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3MDA4NzcsImV4cCI6MjA2MTI3Njg3N30.o3uGNWrn-AFnTZa4eWiTPGDZ01EI_6FjojV3W-mAIoc"

pause