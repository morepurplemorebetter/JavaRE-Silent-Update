:: Makes a task to schedule the updating of JRE
schtasks /Delete /TN "Update JavaRE" /F
schtasks /Create /RU "SYSTEM" /SC WEEKLY /ST 15:55 /TN "Update JavaRE" /TR "'[PATH]\SilentJavaUpdate.vbs'" /v1
