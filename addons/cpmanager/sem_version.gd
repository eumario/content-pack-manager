@tool
class_name SemVersion extends RefCounted

## Creates a Semantic Version class, that can be easily compared.

## Version Major
@export var major : int
## Version Minor
@export var minor : int
## Version Patch Level
@export var patch : int
## Version Stage (dev, prerelease, alpha, beta, rc) with numbered releases (EG: rc1, beta5, alpha3)
@export var stage : String

static var _semVerRegex : RegEx = RegEx.new()
static var _stageRegex : RegEx = RegEx.new()
static var _compiledRegex : bool = false

var _stages : Array[String] = [
	"dev",
	"prerelease",
	"alpha",
	"beta",
	"rc",
]

func _init() -> void:
	if _compiledRegex: return
	_compiledRegex = true
	_semVerRegex.compile(r'^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$')
	_stageRegex.compile(r'^(?P<word>[A-za-z]+)?(?P<release>\d*)$')

func _to_string() -> String:
	return "%s.%s.%s-%s" % [major, minor, patch, stage] if stage != "" else "%s.%s.%s" % [major, minor, patch]

## Parses a String, and returns a new [SemVersion] instance.
static func from_string(version : String) -> SemVersion:
	var ver = SemVersion.new()
	if version.begins_with("v") or version.begins_with("V"): version = version.substr(1,-1)
	var regex_match := _semVerRegex.search(version)
	if regex_match == null:
		return null
	ver.major = int(regex_match.get_string("major")) if "major" in regex_match.names else 0
	ver.minor = int(regex_match.get_string("minor")) if "minor" in regex_match.names else 0
	ver.patch = int(regex_match.get_string("patch")) if "patch" in regex_match.names else 0
	ver.stage = regex_match.get_string("prerelease") if "prerelease" in regex_match.names else ""
	return ver

## Compares this version to another version, and returns an Integer.  If this version is newer than
## the other version, returns [code]1[/code].  If it's older then this version, returns [code]-1[/code],
## otherwise returns [code]0[/code] if the versions are the same.
func compare(version : SemVersion) -> int:
	if major > version.major: return 1
	if major < version.major: return -1
	if minor > version.minor: return 1
	if minor < version.minor: return -1
	if patch > version.patch: return 1
	if patch < version.patch: return -1
	return _compare_stage(version.stage)

func _compare_stage(ostage : String) -> int:
	if stage == "" && ostage != "": return 1
	if stage != "" && ostage == "": return -1
	if stage == ostage: return 0
	
	var regex_match := _stageRegex.search(stage)
	var oregex_match := _stageRegex.search(ostage)
	var i = _stages.find(regex_match.get_string("word").to_lower())
	var oi = _stages.find(oregex_match.get_string("word").to_lower())
	if i > oi: return 1
	if i < oi: return -1
	
	if i == oi:
		if int(regex_match.get_string("release")) > int(oregex_match.get_string("release")): return 1
		if int(regex_match.get_string("release")) < int(oregex_match.get_string("release")): return -1
	
	return 0

## Returns [code]true[/code] if [param version] is equal to this [SemVersion], otherwise returns [code]false[/code].
func equals(version : SemVersion) -> bool:
	return compare(version) == 0

## Returns [code]true[/code] if [param version] is newer than this [SemVersion], otherwise returns [code]false[/code].
func is_newer_than(version : SemVersion) -> bool:
	return compare(version) > 0

## Returns [code]true[/code] if [param version] is older than this [SemVersion], otherwise returns [code]false[/code].
func is_older_than(version : SemVersion) -> bool:
	return compare(version) < 0
