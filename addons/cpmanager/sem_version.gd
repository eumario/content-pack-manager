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
static var _semVerPartialRegex : RegEx = RegEx.new()
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
	_semVerPartialRegex.compile(r'^\d+(?:\.\d+(?:\.\d+)?)?')

func _to_string() -> String:
	return "%s.%s.%s-%s" % [major, minor, patch, stage] if stage != "" else "%s.%s.%s" % [major, minor, patch]

## Checks to see if the version string is a valid Semantic Version formatted string.
static func is_valid_string(version : String) -> bool:
	var regex_match = _semVerRegex.search(version)
	return regex_match != null

## Checks to see if the version string can be coerced into a valid Semantic Version formatted string.
static func is_coerceable_string(version : String) -> bool:
	var regex_match = _semVerPartialRegex.search(version)
	return regex_match != null

## Parses a String, and returns a new [SemVersion] instance.
static func from_string(version : String) -> SemVersion:
	var ver = SemVersion.new()
	assert(version != "", "Invalid empty version string: %s" % version)
	if version.begins_with("v") or version.begins_with("V"): version = version.substr(1,-1)
	var regex_match := _semVerRegex.search(version)
	assert(regex_match != null, "Invalid version string: %s" % version)
	ver.major = int(regex_match.get_string("major")) if "major" in regex_match.names else 0
	ver.minor = int(regex_match.get_string("minor")) if "minor" in regex_match.names else 0
	ver.patch = int(regex_match.get_string("patch")) if "patch" in regex_match.names else 0
	ver.stage = regex_match.get_string("prerelease") if "prerelease" in regex_match.names else ""
	return ver

## Coerce a version into proper Semantic Version formatting.  EG: 4.4-beta1 -> 4.4.0-beta1
static func coerce(version_string : String, partial : bool = false) -> SemVersion:
	if version_string.begins_with("v") or version_string.begins_with("V"): version_string = version_string.substr(1,-1)
	var regex_match := _semVerPartialRegex.search(version_string)
	assert(regex_match != null, "Version string lacks a numerical component: %s" % version_string)
	var version = version_string.substr(0,regex_match.get_end())
	
	if not partial:
		while version.count(".") < 2:
			version += ".0"
	
	version = ".".join(Array(version.split(".")).map(func(x : String): return x.lstrip("0") if x.lstrip("0") != "" else "0"))
	if regex_match.get_end() == len(version_string):
		return from_string(version)
	
	version += version_string.substr(regex_match.get_end(), -1)
	
	return from_string(version)

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
