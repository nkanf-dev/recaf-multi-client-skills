log.info("primary jvm classes = {}", workspace.getPrimaryResource().getJvmClassBundle().size());
var cls = workspace.findJvmClass("HelloRecaf");
log.info("findJvmClass('HelloRecaf') = {}", cls != null);
if (cls != null) {
  log.info("resolved class = {}", cls.getValue().getName());
}
