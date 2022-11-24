FrameworkPathOverride=$(dirname $(which mono))/../lib/mono/4.7.2-api/ dotnet build Source.csproj /property:Configuration=Release
# TODO: on mac, the build dumps all of the system dlls in the Assemblies dir for some reason, which confuses the game
find ../Assemblies -name '*.dll' -not -name Source.dll -delete
