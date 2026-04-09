Recaf recaf = Bootstrap.get();
DecompilerManager dm = recaf.get(DecompilerManager.class);
var cp = workspace.findJvmClass("HelloRecaf");
if (cp == null) throw new RuntimeException("class not found");
JvmClassInfo cls = (JvmClassInfo) cp.getValue();
try {
  DecompileResult r = dm.decompile(workspace, cls).get();
  log.info("decompile ok = {}", r.getText() != null);
  log.info("contains secret method = {}", r.getText() != null && r.getText().contains("secret"));
  if (r.getText() != null) {
    log.info("decompile first line = {}", r.getText().lines().findFirst().orElse("<empty>"));
  }
} catch (Exception e) {
  throw new RuntimeException(e);
}
