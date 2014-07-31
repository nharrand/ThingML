/**
 * Copyright (C) 2014 SINTEF <franck.fleurey@sintef.no>
 *
 * Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, Version 3, 29 June 2007;
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sintef.thingml.impl;

import java.util.*;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EObjectContainmentEList;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.util.InternalEList;

import org.sintef.thingml.*;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Configuration</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * <ul>
 *   <li>{@link org.sintef.thingml.impl.ConfigurationImpl#getInstances <em>Instances</em>}</li>
 *   <li>{@link org.sintef.thingml.impl.ConfigurationImpl#getConnectors <em>Connectors</em>}</li>
 *   <li>{@link org.sintef.thingml.impl.ConfigurationImpl#isFragment <em>Fragment</em>}</li>
 *   <li>{@link org.sintef.thingml.impl.ConfigurationImpl#getConfigs <em>Configs</em>}</li>
 *   <li>{@link org.sintef.thingml.impl.ConfigurationImpl#getPropassigns <em>Propassigns</em>}</li>
 * </ul>
 * </p>
 *
 * @generated
 */
public class ConfigurationImpl extends AnnotatedElementImpl implements Configuration {
	/**
	 * The cached value of the '{@link #getInstances() <em>Instances</em>}' containment reference list.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getInstances()
	 * @generated
	 * @ordered
	 */
	protected EList<Instance> instances;

	/**
	 * The cached value of the '{@link #getConnectors() <em>Connectors</em>}' containment reference list.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getConnectors()
	 * @generated
	 * @ordered
	 */
	protected EList<Connector> connectors;

	/**
	 * The default value of the '{@link #isFragment() <em>Fragment</em>}' attribute.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #isFragment()
	 * @generated
	 * @ordered
	 */
	protected static final boolean FRAGMENT_EDEFAULT = false;

	/**
	 * The cached value of the '{@link #isFragment() <em>Fragment</em>}' attribute.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #isFragment()
	 * @generated
	 * @ordered
	 */
	protected boolean fragment = FRAGMENT_EDEFAULT;

	/**
	 * The cached value of the '{@link #getConfigs() <em>Configs</em>}' containment reference list.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getConfigs()
	 * @generated
	 * @ordered
	 */
	protected EList<ConfigInclude> configs;

	/**
	 * The cached value of the '{@link #getPropassigns() <em>Propassigns</em>}' containment reference list.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getPropassigns()
	 * @generated
	 * @ordered
	 */
	protected EList<ConfigPropertyAssign> propassigns;

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	protected ConfigurationImpl() {
		super();
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	protected EClass eStaticClass() {
		return ThingmlPackage.Literals.CONFIGURATION;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public EList<Instance> getInstances() {
		if (instances == null) {
			instances = new EObjectContainmentEList<Instance>(Instance.class, this, ThingmlPackage.CONFIGURATION__INSTANCES);
		}
		return instances;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public EList<Connector> getConnectors() {
		if (connectors == null) {
			connectors = new EObjectContainmentEList<Connector>(Connector.class, this, ThingmlPackage.CONFIGURATION__CONNECTORS);
		}
		return connectors;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public boolean isFragment() {
		return fragment;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public void setFragment(boolean newFragment) {
		boolean oldFragment = fragment;
		fragment = newFragment;
		if (eNotificationRequired())
			eNotify(new ENotificationImpl(this, Notification.SET, ThingmlPackage.CONFIGURATION__FRAGMENT, oldFragment, fragment));
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public EList<ConfigInclude> getConfigs() {
		if (configs == null) {
			configs = new EObjectContainmentEList<ConfigInclude>(ConfigInclude.class, this, ThingmlPackage.CONFIGURATION__CONFIGS);
		}
		return configs;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public EList<ConfigPropertyAssign> getPropassigns() {
		if (propassigns == null) {
			propassigns = new EObjectContainmentEList<ConfigPropertyAssign>(ConfigPropertyAssign.class, this, ThingmlPackage.CONFIGURATION__PROPASSIGNS);
		}
		return propassigns;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs) {
		switch (featureID) {
			case ThingmlPackage.CONFIGURATION__INSTANCES:
				return ((InternalEList<?>)getInstances()).basicRemove(otherEnd, msgs);
			case ThingmlPackage.CONFIGURATION__CONNECTORS:
				return ((InternalEList<?>)getConnectors()).basicRemove(otherEnd, msgs);
			case ThingmlPackage.CONFIGURATION__CONFIGS:
				return ((InternalEList<?>)getConfigs()).basicRemove(otherEnd, msgs);
			case ThingmlPackage.CONFIGURATION__PROPASSIGNS:
				return ((InternalEList<?>)getPropassigns()).basicRemove(otherEnd, msgs);
		}
		return super.eInverseRemove(otherEnd, featureID, msgs);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public Object eGet(int featureID, boolean resolve, boolean coreType) {
		switch (featureID) {
			case ThingmlPackage.CONFIGURATION__INSTANCES:
				return getInstances();
			case ThingmlPackage.CONFIGURATION__CONNECTORS:
				return getConnectors();
			case ThingmlPackage.CONFIGURATION__FRAGMENT:
				return isFragment();
			case ThingmlPackage.CONFIGURATION__CONFIGS:
				return getConfigs();
			case ThingmlPackage.CONFIGURATION__PROPASSIGNS:
				return getPropassigns();
		}
		return super.eGet(featureID, resolve, coreType);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void eSet(int featureID, Object newValue) {
		switch (featureID) {
			case ThingmlPackage.CONFIGURATION__INSTANCES:
				getInstances().clear();
				getInstances().addAll((Collection<? extends Instance>)newValue);
				return;
			case ThingmlPackage.CONFIGURATION__CONNECTORS:
				getConnectors().clear();
				getConnectors().addAll((Collection<? extends Connector>)newValue);
				return;
			case ThingmlPackage.CONFIGURATION__FRAGMENT:
				setFragment((Boolean)newValue);
				return;
			case ThingmlPackage.CONFIGURATION__CONFIGS:
				getConfigs().clear();
				getConfigs().addAll((Collection<? extends ConfigInclude>)newValue);
				return;
			case ThingmlPackage.CONFIGURATION__PROPASSIGNS:
				getPropassigns().clear();
				getPropassigns().addAll((Collection<? extends ConfigPropertyAssign>)newValue);
				return;
		}
		super.eSet(featureID, newValue);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public void eUnset(int featureID) {
		switch (featureID) {
			case ThingmlPackage.CONFIGURATION__INSTANCES:
				getInstances().clear();
				return;
			case ThingmlPackage.CONFIGURATION__CONNECTORS:
				getConnectors().clear();
				return;
			case ThingmlPackage.CONFIGURATION__FRAGMENT:
				setFragment(FRAGMENT_EDEFAULT);
				return;
			case ThingmlPackage.CONFIGURATION__CONFIGS:
				getConfigs().clear();
				return;
			case ThingmlPackage.CONFIGURATION__PROPASSIGNS:
				getPropassigns().clear();
				return;
		}
		super.eUnset(featureID);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public boolean eIsSet(int featureID) {
		switch (featureID) {
			case ThingmlPackage.CONFIGURATION__INSTANCES:
				return instances != null && !instances.isEmpty();
			case ThingmlPackage.CONFIGURATION__CONNECTORS:
				return connectors != null && !connectors.isEmpty();
			case ThingmlPackage.CONFIGURATION__FRAGMENT:
				return fragment != FRAGMENT_EDEFAULT;
			case ThingmlPackage.CONFIGURATION__CONFIGS:
				return configs != null && !configs.isEmpty();
			case ThingmlPackage.CONFIGURATION__PROPASSIGNS:
				return propassigns != null && !propassigns.isEmpty();
		}
		return super.eIsSet(featureID);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public String toString() {
		if (eIsProxy()) return super.toString();

		StringBuffer result = new StringBuffer(super.toString());
		result.append(" (fragment: ");
		result.append(fragment);
		result.append(')');
		return result.toString();
	}


    /**
     * @generated NOT
     */
    private static class MergedConfigurationCache {

        static Map<Configuration, Configuration> cache = new HashMap<Configuration, Configuration>();

        static Configuration getMergedConfiguration(Configuration c) {
            return cache.get(c);
        }

        static void cacheMergedConfiguration(Configuration c, Configuration mc)  {
            cache.put(c, mc);
        }

        static void clearCache() {
            cache.clear();
        }

    }

    /**
     *
     * @return
     * @generated NOT
     */
    private Configuration merge() {

        if (MergedConfigurationCache.getMergedConfiguration(this) != null)
            return MergedConfigurationCache.getMergedConfiguration(this);

        final Configuration copy = EcoreUtil.copy(this);
        final Map<String, Instance> instances = new HashMap<String, Instance>();
        final List<Connector> connectors = new ArrayList<Connector>();
        final Map<String, ConfigPropertyAssign> assigns = new HashMap<String, ConfigPropertyAssign>();
        final String prefix = getName();

        _merge(instances, connectors, assigns, prefix);

        copy.getConfigs().clear();
        copy.getInstances().clear();
        copy.getConnectors().clear();
        copy.getPropassigns().clear();

        copy.getInstances().addAll(instances.values());
        copy.getConnectors().addAll(connectors);
        copy.getPropassigns().addAll(assigns.values());

        MergedConfigurationCache.cacheMergedConfiguration(this, copy);

        return copy;
    }

    /**
     *
     * @param instances
     * @param connectors
     * @param assigns
     * @param prefix
     * @generated NOT
     */
    private void _merge(Map<String, Instance> instances, List<Connector> connectors, Map<String, ConfigPropertyAssign> assigns, String prefix) {
        // Recursively deal with all groups first
        for(ConfigInclude g : getConfigs()) {
            ((ConfigurationImpl)g.getConfig())._merge(instances, connectors, assigns, prefix + "_" + g.getName());
        }

        // Add the instances of this configuration (actually a copy)
        for(Instance inst : getInstances()) {

            final String key = prefix + "_" + inst.getName();
            Instance copy = null;

            if (inst.getType().isSingleton()) {
                // TODO: This could become slow if we have a large number of instances
                List<Instance> others = new ArrayList<Instance>();
                for(Instance i : instances.values()) {
                    if (i.getType().equals(inst.getType())) {
                        others.add(i);
                    }
                }
                if (others.isEmpty()) {
                    copy = EcoreUtil.copy(inst);
                    copy.setName(inst.getName()); // no prefix needed
                }
                else copy = others.get(0); // There will be only one in the list
            }
            else {
                copy = EcoreUtil.copy(inst);
                copy.setName(key); // rename the instance with the prefix
            }

            instances.put(key, copy);
        }

        // Add the connectors
        for(Connector c : getConnectors()) {
            Connector copy = EcoreUtil.copy(c);
            // look for the instances:
            Instance cli = instances.get(getInstanceMergedName(prefix, c.getCli()));
            Instance srv = instances.get(getInstanceMergedName(prefix, c.getSrv()));

            copy.getCli().getConfig().clear();
            copy.getCli().setInstance(cli);

            copy.getSrv().getConfig().clear();
            copy.getSrv().setInstance(srv);

            connectors.add(copy);
        }

        for(ConfigPropertyAssign a : getPropassigns()) {
            ConfigPropertyAssign copy = EcoreUtil.copy(a);

            String inst_name = getInstanceMergedName(prefix, a.getInstance());

            Instance inst = instances.get(inst_name);
            copy.getInstance().getConfig().clear();
            copy.getInstance().setInstance(inst);

            String id = inst_name + "_" + a.getProperty().getName();

            if (a.getIndex().size() > 0)  { // It is an array
                id += a.getIndex().get(0);
                //println(id)
            }

            assigns.put(id, copy); // This will replace any previous initialization of the variable
        }

    }

    /**
     *
     * @param prefix
     * @param ref
     * @return
     * @generated NOT
     */
    private String getInstanceMergedName(String prefix, InstanceRef ref) {
        String result = prefix;
        for (ConfigInclude c : ref.getConfig()) {
            result += "_" + c.getName();
        }
        result += "_" + ref.getInstance().getName();
        return result;
    }

    /**
     *
     * @return
     * @generated NOT
     */
    public Map<Instance, String[]> allRemoteInstances() {
        Map<Instance, String[]> result = new HashMap<Instance, String[]>();
        for (PlatformAnnotation a : getAnnotations()) {
            if (a.getName().equals("remote")) {
                final String[] regex = a.getValue().split("::");
                for(Instance i : allInstances()) {
                    if (i.getName().matches(getName()+"_"+regex[0]) && i.getType().getName().matches(regex[1]) ) {
                        result.put(i, regex);
                    }
                }
            }
        }
        return result;
    }

    /**
     *
     * @return
     * @generated NOT
     */
    public Set<Instance> allInstances() {
        Set<Instance> result = new HashSet<Instance>();
        result.addAll(merge().getInstances());
        return result;
    }

    /**
     *
     * @return
     * @generated NOT
     */
    public Set<Connector> allConnectors() {
        Set<Connector> result = new HashSet<Connector>();
        result.addAll(merge().getConnectors());
        return result;
    }

    /**
     *
     * @return
     * @generated NOT
     */
    public Set<ConfigPropertyAssign> allPropAssigns() {
        Set<ConfigPropertyAssign> result = new HashSet<ConfigPropertyAssign>();
        result.addAll(merge().getPropassigns());
        return result;
    }

} //ConfigurationImpl
