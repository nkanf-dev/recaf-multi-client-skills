Recaf recaf = Bootstrap.get();
JavacCompiler javac = recaf.get(JavacCompiler.class);
var primary = workspace.getPrimaryResource();
JvmClassBundle bundle = primary.getJvmClassBundle();
String source = "public " + "class" + " HelloRecaf {\n"
    + "  public static void main(String[] args) {\n"
    + "    System.out.println(secret());\n"
    + "  }\n"
    + "  public static String secret() {\n"
    + "    return \"patched-by-recaf\";\n"
    + "  }\n"
    + "}\n";
JavacArguments args = new JavacArguments(
    "HelloRecaf",
    source,
    null,
    22,
    -1,
    true,
    true,
    true
);
CompilerResult result = javac.compile(args, workspace, null);
if (!result.wasSuccess()) {
  log.error("compile success? {}", result.wasSuccess());
  for (var d : result.getDiagnostics()) {
    log.error("compile diagnostic: {}", d);
  }
  if (result.getException() != null) {
    throw new RuntimeException(result.getException());
  }
  throw new RuntimeException("compile failed");
}
byte[] bytes = result.getCompilations().get("HelloRecaf");
if (bytes == null) throw new RuntimeException("missing compilation output");
JvmClassInfo updated = new JvmClassInfoBuilder(bytes).build();
bundle.put(updated);
log.info("dirty keys after put = {}", bundle.getDirtyKeys());
Path out = Paths.get("/tmp/hello-recaf-patched.jar");
WorkspaceExportOptions options = new WorkspaceExportOptions(
    WorkspaceCompressType.MATCH_ORIGINAL,
    WorkspaceOutputType.FILE,
    new PathWorkspaceExportConsumer(out)
);
WorkspaceExporter exporter = options.create();
try {
  exporter.export(workspace);
} catch (Exception e) {
  throw new RuntimeException(e);
}
log.info("exported patched jar to {}", out);
