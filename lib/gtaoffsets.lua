gta_offset_types = {
    CAmmoInfo={
        Model={0x0014, "hash"},
        Audio={0x0018, "hash"},
        AmmoMax={0x0020, "int"},
        AmmoMax50={0x0024, "int"},
        AmmoMax100={0x0028, "int"},
        AmmoMaxMP={0x002C, "int"},
        AmmoMax50MP={0x0030, "int"},
        AmmoMax100MP={0x0034, "int"},
        AmmoFlags={0x0038, "flags32"},
        AmmoSpecialType={0x003c, "enum"},
        -- The all entris following are for projectiles only!
        Damage={0x0040, "float"},
        LifeTime={0x0044, "float"},
        FromVehicleLifeTime={0x0048, "float"},
        LifeTimeAfterImpact={0x004c, "float"},
        LifeTimeAfterExplosion={0x0050, "float"},
        ExplosionTime={0x0054, "float"},
        LaunchSpeed={0x0058, "float"},
        SeparationTime={0x005c, "float"},
        TimeToReachTarget={0x0060, "float"},
        Damping={0x0064, "float"},
        GravityFactor={0x0068, "float"},
        RicochetTolerance={0x006c, "float"},
        PedRicochetTolerance={0x0070, "float"},
        VehicleRicochetTolerance={0x0074, "float"},
        FrictionMultiplier={0x0078, "float"},
        Explosion={
            _base=0x007C,
            Default={0x00, "enum"},
            HitCar={0x04, "enum"},
            HitTruck={0x08, "enum"},
            HitBike={0x0C, "enum"},
            HitBoat={0x10, "enum"},
            HitPlane={0x14, "enum"}
        },
        FuseFx={0x0094, "hash"},
        ProximityFx={0x0098, "hash"},
        TrailFx={0x009c, "hash"},
        TrailFxUnderWater={0x00a0, "hash"},
        PrimedFx={0x00a4, "hash"},
        FuseFxFP={0x00a8, "hash"},
        PrimedFxFP={0x00ac, "hash"},
        TrailFxFadeInTime={0x00b0, "float"},
        TrailFxFadeOutTime={0x00b4, "float"},
        DisturbFxDefault={0x00b8, "hash"},
        DisturbFxSand={0x00bc, "hash"},
        DisturbFxWater={0x00c0, "hash"},
        DisturbFxDirt={0x00c4, "hash"},
        DisturbFxFoliage={0x00c8, "hash"},
        DisturbFxProbeDist={0x00cc, "float"},
        DisturbFxScale={0x00d0, "float"},
        GroundFxProbeDistance={0x00d4, "float"},
        FxAltTintColour={0x00d8, "bool"},
        LightOnlyActiveWhenStuck={0x00d9, "bool"},
        LightFlickers={0x00da, "bool"},
        LightSpeedsUp={0x00db, "bool"},
        LightBone={0x00dc, "int16"},        
        LightColour={0x00e0, "vec3"},
        LightIntensity={0x00f0, "float"},
        LightRange={0x00f4, "float"},
        LightFalloffExp={0x00f8, "float"},
        LightFrequency={0x00fc, "float"},
        LightPower={0x0100, "float"},
        CoronaSize={0x0104, "float"},
        CoronaIntensity={0x0108, "float"},
        CoronaZBias={0x010c, "float"},        
        ProximityAffectsFiringPlayer={0x0110, "bool"},
        ProximityCanBeTriggeredByPeds={0x0111, "bool"},
        ProximityActivationTime={0x0114, "float"},
        ProximityRepeatedDetonationActivationTime={0x0118, "float"},
        ProximityTriggerRadius={0x011c, "float"},
        ProximityFuseTimePed={0x0120, "float"},
        ProximityFuseTimeVehicleMin={0x0124, "float"},
        ProximityFuseTimeVehicleMax={0x0128, "float"},
        ProximityFuseTimeVehicleSpeed={0x012c, "float"},
        ProximityLightColourUntriggered={0x0130, "vec3"},
        ProximityLightFrequencyMultiplierTriggered={0x0140, "float"},
        TimeToIgnoreOwner={0x0144, "float"},
        ChargedLaunchTime={0x0148, "float"},
        ChargedLaunchSpeedMult={0x014c, "float"},
        ClusterExplosionTag={0x0150, "enum"},
        ClusterExplosionCount={0x0154, "int"},
        ClusterMinRadius={0x0158, "float"},
        ClusterMaxRadius={0x015c, "float"},
        ClusterInitialDelay={0x0160, "float"},
        ClusterInbetweenDelay={0x0164, "float"},
        ProjectileFlags={0x0168, "flags32"},
        -- The following 3 are for thrown weapons only!
        ThrownForce={0x0170, "float"},
        ThrownForceFromVehicle={0x0174, "float"},
        AmmoMaxMPBonus={0x0178, "float"},
        -- The following are for rocket weapons only!
        ForwardDragCoeff={0x0170, "float"},
        SideDragCoeff={0x0174, "float"},
        TimeBeforeHoming={0x0178, "float"},
        TimeBeforeSwitchTargetMin={0x017c, "float"},
        TimeBeforeSwitchTargetMax={0x0180, "float"},
        ProximityRadius={0x0184, "float"},
        PitchChangeRate={0x0188, "float"},
        YawChangeRate={0x018c, "float"},
        RollChangeRate={0x0190, "float"},
        MaxRollAngleSin={0x0194, "float"},
        LifeTimePlayerVehicleLockedOverrideMP={0x0198, "float"},
        HomingRocketParams={-- 0x019c
            ShouldUseHomingParamsFromInfo={0x019c, "bool"},
            ShouldIgnoreOwnerCombatBehaviour={0x019c+0x01, "bool"},
            TimeBeforeStartingHoming={0x019c+0x04, "float"},
            TimeBeforeHomingAngleBreak={0x019c+0x08, "float"},
            TurnRateModifier={0x019c+0x0c, "float"},
            PitchYawRollClamp={0x019c+0x10, "float"},
            DefaultHomingRocketBreakLockAngle={0x019c+0x14, "float"},
            DefaultHomingRocketBreakLockAngleClose={0x019c+0x18, "float"},
            DefaultHomingRocketBreakLockCloseDistance={0x019c+0x1c, "float"}
        }
    },
    CWeaponInfo={
        Model={0x0014, "hash"},
        Audio={0x0018, "hash"},
        DamageType={0x0020, "enum"},
        Explosion={
            _base=0x0024,
            Default={0x00, "enum"},
            HitCar={0x04, "enum"},
            HitTruck={0x08, "enum"},
            HitBike={0x0C, "enum"},
            HitBoat={0x10, "enum"},
            HitPlane={0x14, "enum"}
        },
        FireType={0x0054, "enum"},
        AmmoInfo={0x0060, "ref_ammo"},
        -- AimingInfo={0x0068, "ref_aiming"}, -- tricky to handle
        ClipSize={0x0070, "int"}, -- doesn't seem to work
        AccuracySpread={0x0074, "float"},
        AccurateModeAccuracyModifier={0x0078, "float"},
        RunAndGunAccuracyModifier={0x007c, "float"},
        RunAndGunAccuracyMinOverride={0x0080, "float"},
        RecoilAccuracyMax={0x0084, "float"},
        RecoilErrorTime={0x0088, "float"},
        RecoilRecoveryRate={0x008c, "float"},
        RecoilAccuracyToAllowHeadShotAI={0x0090, "float"},
        MinHeadShotDistanceAI={0x0094, "float"},
        MaxHeadShotDistanceAI={0x0098, "float"},
        HeadShotDamageModifierAI={0x009c, "float"},
        RecoilAccuracyToAllowHeadShotPlayer={0x00a0, "float"},
        MinHeadShotDistancePlayer={0x00a4, "float"},
        MaxHeadShotDistancePlayer={0x00a8, "float"},
        HeadShotDamageModifierPlayer={0x00ac, "float"},
        Damage={0x00B0, "float"},
        DamageTime={0x00B0, "float"},
        DamageTimeInVehicle={0x00b4, "float"},
        DamageTimeInVehicleHeadShot={0x00bc, "float"},
        HitLimbsDamageModifier={0x00c8, "float"},
        NetworkHitLimbsDamageModifier={0x00cc, "float"},
        LightlyArmouredDamageModifier={0x00d0, "float"},
        VehicleDamageModifier={0x00d4, "float"},
        Force={0x00d8, "float"},
        ForceHitPed={0x00dc, "float"},
        ForceHitVehicle={0x00e0, "float"},
        ForceHitFlyingHeli={0x00e4, "float"},
        -- OverrideForces={0x00e8, "ref_forces"}, -- tricky to handle
        ForceMaxStrengthMult={0x00f8, "float"},
        ForceFalloffRangeStart={0x00fc, "float"},
        ForceFalloffRangeEnd ={0x0100, "float"},
        ForceFalloffMin={0x0104, "float"},
        ProjectileForce={0x0108, "float"},
        FragImpulse={0x010c, "float"},
        Penetration={0x0110, "float"},
        VerticalLaunchAdjustment={0x0114, "float"},
        DropForwardVelocity={0x0118, "float"},
        Speed={0x011c, "float"},
        BulletsInBatch={0x0120, "int"},
        BatchSpread={0x0124, "float"},
        ReloadTimeMP={0x0128, "float"},
        ReloadTimeSP={0x012c, "float"},
        VehicleReloadTime={0x0130, "float"},
        AnimReloadRate={0x0134, "float"},
        BulletsPerAnimLoop={0x0138, "int"},
        TimeBetweenShots={0x013c, "float"},
        TimeLeftBetweenShotsWhereShouldFireIsCached={0x0140, "float"},
        SpinUpTime={0x0144, "float"},
        SpinTime={0x0148, "float"},
        SpinDownTime={0x014c, "float"},
        AlternateWaitTime={0x0150, "float"},
        BulletBendingNearRadius={0x0154, "float"},
        BulletBendingFarRadius={0x0158, "float"},
        BulletBendingZoomedRadius={0x015c, "float"},
        FirstPersonBulletBendingNearRadius={0x0160, "float"},
        FirstPersonBulletBendingFarRadius={0x0164, "float"},
        FirstPersonBulletBendingZoomedRadius={0x0168, "float"},
        Fx={
            _base=0x0170,
            EffectGroup={0x0, "enum"},
            FlashFx={0x4, "hash"},
            FlashFxAlt={0x8, "hash"},
            FlashFxFP={0xc, "hash"},
            FlashFxFPAlt={0x10, "hash"},
            MuzzleSmokeFx={0x14, "hash"},
            MuzzleSmokeFxFP={0x18, "hash"},
            MuzzleSmokeFxMinLevel={0x1c, "float"},
            MuzzleSmokeFxIncPerShot={0x20, "float"},
            MuzzleSmokeFxDecPerSec={0x24, "float"},
            MuzzleOverrideOffset={0x30, "vec3"},
            ShellFx={0x44, "hash"},
            ShellFxFP={0x48, "hash"},
            TracerFx={0x4c, "hash"},
            PedDamageHash={0x50, "hash"},
            TracerFxChanceSP={0x54, "float"},
            TracerFxChanceMP={0x58, "float"},
            FlashFxChanceSP={0x60, "float"},
            FlashFxChanceMP={0x64, "float"},
            FlashFxAltChance={0x68, "float"},
            FlashFxScale={0x6c, "float"},
            FlashFxLightEnabled={0x70, "bool"},
            FlashFxLightCastsShadows={0x71, "bool"},
            FlashFxLightOffsetDist={0x74, "float"},
            FlashFxLightRGBAMin={0x80, "vec3"},
            FlashFxLightRGBAMax={0x90, "vec3"},
            FlashFxLightIntensityMinMax={0xa0, "vec2"},
            FlashFxLightRangeMinMax={0xa8, "vec2"},
            FlashFxLightFalloffMinMax={0xb0, "vec2"},
            GroundDisturbFxEnabled={0xb8, "bool"},
            GroundDisturbFxDist={0xbc, "float"},
            GroundDisturbFxNameDefault={0xc0, "hash"},
            GroundDisturbFxNameSand={0xc4, "hash"},
            GroundDisturbFxNameDirt={0xc8, "hash"},
            GroundDisturbFxNameWater={0xcc, "hash"},
            GroundDisturbFxNameFoliage={0xd0, "hash"}
        },
        InitialRumbleDuration={0x0250, "int"},
        InitialRumbleIntensity={0x0254, "float"},
        InitialRumbleIntensityTrigger={0x0258, "float"},
        RumbleDuration={0x025c, "int"},
        RumbleIntensity={0x0260, "float"},
        RumbleIntensityTrigger={0x0264, "float"},
        RumbleDamageIntensity={0x0268, "float"},
        InitialRumbleDurationFps={0x026c, "int"},
        InitialRumbleIntensityFps={0x0270, "float"},
        RumbleDurationFps={0x0274, "int"},
        RumbleIntensityFps={0x0278, "float"},
        NetworkPlayerDamageModifier={0x027c, "float"},
        NetworkPedDamageModifier={0x0280, "float"},
        NetworkHeadShotPlayerDamageModifier={0x0284, "float"},
        LockOnRange={0x0288, "float"},
        WeaponRange={0x028c, "float"},
        
        DefaultCameraHash={0x02b8, "hash"},

        ReticuleStyleHash={0x05ac, "hash"},
        FirstPersonReticuleStyleHash={0x05b0, "hash"},
        MovementModeConditionalIdle={0x05c4, "hash"},

        AttachPoints={
            0x0604, "array",
            ItemTemplate={
                -- _base set at runtime
                AttachBone={0x00, "hash"},
                Components={
                    0x08, "array",
                    ItemTemplate={
                        -- _base set at runtime
                        Name={0x00, "hash"},
                        Default={0x04, "bool"}
                    },
                    ItemSize=0x8,
                    Count={0x68, "int"}
                }
            },
            ItemSize=0x6c,
            Count={0x08f8, "int"}
        },
        WeaponFlags={0x0900, "flags192"},
        AirborneAircraftLockOnMultiplier={0x0968, "float"},
    },
}