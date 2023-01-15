{{- define "get.labels" }}
{{- with (.metadata).labels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "get.annotations" }}
{{- with (.metadata).annotations }}
{{- toYaml . -}}
{{- end }}
{{- end }}

{{- define "config.checksum" }}
{{- $conf := dict ".configMaps" .configMaps ".secrets" .secrets ".sealedSecrets" .sealedSecrets -}}
checksum.config: "{{ toJson $conf | sha1sum }}"
{{- end }}

{{- define "spec.containers" }}
{{- range $containerName, $containerConf := . }}
- name: {{ $containerName }}
  image: {{ $containerConf.image.repository }}:{{ $containerConf.image.tag }}
  {{- with $containerConf.imagePullPolicy }}
  imagePullPolicy: {{ $containerConf.imagePullPolicy }}
  {{- end }}
  {{- with $containerConf.entrypoint }}
  entrypoint:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.args }}
  args:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.workingDir }}
  workingDir: {{ . }}
  {{- end }}
  {{- with $containerConf.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.terminationMessagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with $containerConf.terminationMessagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}
  {{- with $containerConf.livenessProbe }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $containerConf.stdin }}
  stdin: {{ . }}
  {{- end }}
  {{- with $containerConf.stdinOnce }}
  stdinOnce: {{ . }}
  {{- end }}
  {{- with $containerConf.tty }}
  tty: {{ . }}
  {{- end }}
  {{- if $containerConf.env }}
  env:
    {{- range $varName, $varSpec := $containerConf.env }}
    - name: {{ $varName }}
      {{- if kindIs "map" $varSpec }}
      {{- toYaml $varSpec | nindent 6 }}
      {{- else }}
      value: "{{ $varSpec }}"
      {{- end }}
    {{- end }}
  {{- end }}
  {{- with $containerConf.envFrom }}
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with $containerConf.mounts }}
  volumeMounts:
    {{- range $mountPath, $mountConf := . }}
    - name: {{ $mountConf.volume }}
      mountPath: {{ $mountPath }}
      {{- with $mountConf.mountPropagation }}
      mountPropagation: {{ . }}
      {{- end }}
      {{- with $mountConf.readOnly }}
      readOnly: {{ . }}
      {{- end }}
      {{- with $mountConf.subPath }}
      subPath: {{ . }}
      {{- end }}
      {{- with $mountConf.subPathExpr }}
      subPathExpr: {{ . }}
      {{- end }}
  {{- end }}
  {{- end }}
  {{- if $containerConf.ports }}
  ports:
  {{- range $portName, $portConf := $containerConf.ports }}
    - name: {{ $portName }}
      {{- with $portConf.containerPort }}
      containerPort: {{ . }}
      {{- end }}
      {{- with $portConf.hostIP }}
      hostIP: {{ . }}
      {{- end }}
      {{- with $portConf.hostPort }}
      hostPort: {{ . }}
      {{- end }}
      {{- with $portConf.protocol }}
      protocol: {{ . }}
      {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "spec.pod" }}
{{- with .affinity }}
affinity:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .automountServiceAccountToken }}
automountServiceAccountToken: {{ . }}
{{- end }}
{{- with .dnsConfig }}
dnsConfig:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .enableServiceLinks }}
enableServiceLinks: {{ . }}
{{- end }}
{{- with .hostAliases }}
hostAliases:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .hostIPC }}
hostIPC: {{ . }}
{{- end }}
{{- with .hostNetwork }}
hostNetwork: {{ . }}
{{- end }}
{{- with .hostPID }}
hostPID: {{ . }}
{{- end }}
{{- with .hostname }}
hostname: {{ . }}
{{- end }}
{{- with .imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .nodename }}
nodename: {{ . }}
{{- end }}
{{- with .nodeSelector }}
nodeSelector:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .overhead }}
overhead:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .os }}
os:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .volumes }}
volumes:
{{- range $volName, $volConf := . }}
  - name: {{ $volName }}
    {{- toYaml $volConf | nindent 4 }}
{{- end }}
{{- end }}
{{- with .tolerations }}
tolerations:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .schedulerName }}
schedulerName: {{ . }}
{{- end }}
containers:
{{- include "spec.containers" .containers | nindent 2 }}
{{- with .runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with .priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .priority }}
priority: {{ . }}
{{- end }}
{{- with .preemptionPolicy }}
preemptionPolicy: {{ . }}
{{- end }}
{{- with .topologySpreadConstraints }}
topologySpreadConstraints:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .restartPolicy }}
restartPolicy: {{ . }}
{{- end }}
{{- with .terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- with .activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
{{- with .readinessGates }}
readinessGates:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .setHostnameAsFQDN }}
setHostnameAsFQDN: {{ . }}
{{- end }}
{{- with .subdomain }}
subdomain: {{ . }}
{{- end }}
{{- with .shareProcessNamespace }}
shareProcessNamespace: {{ . }}
{{- end }}
{{- with .serviceAccountName }}
serviceAccountName: {{ . }}
{{- end }}
{{- with .securityContext }}
securityContext:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
